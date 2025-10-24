import time
import logging
import random
from difflib import SequenceMatcher

from django.utils import timezone
from django.db import transaction
from django.core.management.base import BaseCommand

from product_app.scraper_sites import SCRAPER_REGISTRY
from product_app.models import Trend, Category
from product_app.utils import get_current_season
from product_app.tasks import compute_hot_trends

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Scrape seasonal fashion trends from configured sites and store or preview results."

    def add_arguments(self, parser):
        parser.add_argument("--season", type=str, default=None, help="Override the detected fashion season.")
        parser.add_argument("--sites", type=str, default="vogue,asos,pinterest,googletrends",
                            help="Comma-separated list of sites to scrape.")
        parser.add_argument("--no-save", action="store_true",
                            help="Dry run: scrape and deduplicate but don't save to DB.")
        parser.add_argument("--max-trends", type=int, default=50,
                            help="Maximum number of unique trends to keep after deduplication.")
        parser.add_argument("--verbose-sites", action="store_true",
                            help="Show detailed per-site progress (useful for debugging individual scrapers).")

    def handle(self, *args, **options):
        season = options.get("season") or get_current_season()
        site_list = [s.strip().lower() for s in options["sites"].split(",") if s.strip()]
        dry_run = options.get("no_save")
        verbose = options.get("verbose_sites")

        category, _ = Category.objects.get_or_create(name="Clothing")

        self.stdout.write(self.style.NOTICE(f"=== Scraping trends for {season} ==="))
        self.stdout.write(f"Sites: {', '.join(site_list)}")
        if dry_run:
            self.stdout.write(self.style.WARNING("Dry run enabled — results will NOT be saved."))

        all_trends = []

        # === Scrape from each configured site ===
        for site in site_list:
            scraper_cls = SCRAPER_REGISTRY.get(site)
            if not scraper_cls:
                self.stdout.write(self.style.WARNING(f"⚠️  No scraper implemented for {site}, skipping."))
                continue

            self.stdout.write(self.style.SQL_FIELD(f"\n▶ Scraping {site.capitalize()}..."))
            try:
                scraper = scraper_cls(season)
                start = time.time()
                results = scraper.fetch() or []
                elapsed = time.time() - start

                if verbose:
                    self.stdout.write(f"    {len(results)} items fetched in {elapsed:.1f}s")

                for r in results:
                    # Handle missing or inconsistent data gracefully
                    kw = (r.get("keywords") or r.get("title") or "").strip()
                    if not kw:
                        continue
                    r["keywords_lower"] = kw.lower()
                    r["keywords"] = kw[:1000]
                    r.setdefault("popularity_score", 0.0)
                    r.setdefault("source_url", "")
                    r.setdefault("source_name", site.capitalize())

                all_trends.extend(results)

            except Exception as exc:
                logger.exception(f"Error scraping {site}: {exc}")
                self.stdout.write(self.style.ERROR(f"❌ {site.capitalize()} failed: {exc}"))
                continue
            finally:
                sleep_time = random.uniform(2.0, 5.0)
                self.stdout.write(f"⏸ Sleeping {sleep_time:.1f}s before next site...")
                time.sleep(sleep_time)

        # === Deduplication ===
        unique_trends = self._deduplicate_trends(all_trends)
        if len(unique_trends) > options["max_trends"]:
            unique_trends = unique_trends[:options["max_trends"]]

        self.stdout.write(self.style.SUCCESS(
            f"\n✅ Collected {len(unique_trends)} unique trends across {len(site_list)} sites."
        ))

        # === Dry run or Save ===
        if dry_run:
            for t in unique_trends[:10]:
                title = t.get("keywords") or t.get("title") or "Unnamed trend"
                source = t.get("source_name", "Unknown")
                score = t.get("popularity_score", 0.0)
                self.stdout.write(f" • {title}  ({source}, {score:.1f})")

            self.stdout.write(self.style.SUCCESS("\nDry run complete — no data saved."))
            return

        # === Save to DB ===
        saved = 0
        with transaction.atomic():
            for t in unique_trends:
                title = t.get("keywords") or t.get("title") or "Unnamed trend"
                obj, created = Trend.objects.update_or_create(
                    season=season,
                    keywords=title,
                    defaults={
                        "popularity_score": float(t.get("popularity_score", 0.0)),
                        "category": category,
                        "source_url": t.get("source_url", ""),
                        "source_name": t.get("source_name", ""),
                    },
                )
                if created:
                    saved += 1

        self.stdout.write(self.style.SUCCESS(f"💾 Saved {saved} new trends."))

        # === Post-process ===
        result = compute_hot_trends(season)
        self.stdout.write(self.style.SUCCESS(f"🔥 {result}"))

    def _deduplicate_trends(self, trends):
        unique = {}
        for trend in trends:
            # Safely handle missing keys
            keywords = trend.get("keywords") or trend.get("title") or ""
            if not keywords:
                continue  # skip incomplete entries

            key = trend.get("keywords_lower", keywords.lower())
            if key not in unique:
                unique[key] = trend
        return list(unique.values())