# Core Python/Standard Library imports
import time # Used for adding delays between scraper runs
import logging # For logging errors and informational messages
import random # Used to generate random, jittered delays

# Django framework imports
from django.utils import timezone # Not explicitly used, but generally useful for time-aware operations (kept for context)
from django.db import transaction # Used to ensure database writes are atomic (all or nothing)
from django.core.management.base import BaseCommand # The base class for creating management commands

# Application-specific imports
from product_app.scraper_sites import SCRAPER_REGISTRY # A dictionary/registry mapping site names (e.g., 'vogue') to their scraper classes
from product_app.models import Trend, Category # Django models for saving trend and category data
from product_app.utils import get_current_season # Utility function to determine the current fashion season (e.g., 'Spring 2025')
from product_app.tasks import compute_hot_trends # Celery task (or function in this context) to process the collected trends
from difflib import SequenceMatcher # Standard library module for measuring sequence (string) similarity, used for similarity-based dedup

# Set up the logger for this module
logger = logging.getLogger(__name__)


# Define the custom Django management command
class Command(BaseCommand):
    # Short description displayed when running 'python manage.py help scrape_trends'
    help = "Scrape seasonal clothing trends from configured sites"

    # Define command-line arguments the user can pass
    def add_arguments(self, parser):
        # Optional: Allows overriding the auto-detected season
        parser.add_argument("--season", type=str, default=None)
        # Allows specifying which sites to scrape, defaults to a list of sites
        parser.add_argument("--sites", type=str, default="vogue,asos,pinterest")
        # Flag for a dry run: scrape data but do not save to the database
        parser.add_argument("--no-save", action="store_true", help="Run scrapers but don't save to DB (dry run)")
        # Limits the total number of unique trends to save
        parser.add_argument("--max-trends", type=int, default=50, help="Max total trends to collect/save")

    # The main logic of the command
    def handle(self, *args, **options):
        # Determine the season: use the argument or the current season utility
        season = options.get("season") or get_current_season()
        # Parse the comma-separated site list argument
        site_list = [s.strip() for s in options.get("sites", "").split(",") if s.strip()]
        # Get or create the 'Clothing' category for trend association
        category = Category.objects.filter(name__icontains="Clothing").first() or Category.objects.create(name="Clothing")

        # Notify the user the process is starting
        self.stdout.write(self.style.NOTICE(f"Starting scrape for season={season} sites={site_list}"))

        all_trends = [] # List to accumulate trend data from all sites

        # --- Scrape Data from Configured Sites ---
        for site in site_list:
            # Look up the appropriate scraper class from the registry
            scraper_cls = SCRAPER_REGISTRY.get(site.lower())
            if not scraper_cls:
                self.stdout.write(self.style.WARNING(f"No scraper implemented for {site}, skipping."))
                continue

            try:
                self.stdout.write(self.style.SQL_FIELD(f"Scraping {site}..."))
                # Instantiate the scraper for the current season
                scraper = scraper_cls(season)
                # Execute the scraper's fetching logic
                results = scraper.fetch() or []
                if not results:
                    self.stdout.write(self.style.WARNING(f"No results from {site} for {season}"))
                    continue

                # Prepare the scraped results for saving/deduplication
                for r in results:
                    keywords = (r.get("keywords") or "").strip()
                    if keywords:
                        # Create a lowercase version for case-insensitive deduplication
                        r["keywords_lower"] = keywords.lower()
                    # Truncate keywords to prevent database field overflow
                    r["keywords"] = keywords[:1000]
                    # Ensure required fields have defaults
                    r.setdefault("popularity_score", 0.0)
                    r.setdefault("source_url", "")
                    r.setdefault("source_name", site)

                all_trends.extend(results)

                # Add a random, 'jittered' delay to mimic human behavior and avoid bot detection
                sleep_time = random.uniform(2.0, 5.0)
                self.stdout.write(f"Sleeping {sleep_time:.1f}s before next site...")
                time.sleep(sleep_time)

            except Exception as exc:
                # Log any exception encountered during the scraping process
                logger.exception(f"Error scraping {site}: {exc}")
                self.stdout.write(self.style.ERROR(f"Error scraping {site}: {exc}"))
                continue

        # --- Deduplication and Limiting ---
        # Deduplicate the collected trends across all sites using keyword similarity
        unique_trends = self._deduplicate_trends(all_trends)
        
        # Apply the user-specified limit on total trends
        if len(unique_trends) > options.get("max_trends", 50):
            unique_trends = unique_trends[:options["max_trends"]]

        # Handle the dry-run scenario
        if options.get("no_save"):
            self.stdout.write(self.style.SUCCESS(f"Dry run complete. {len(unique_trends)} unique items collected."))
            return

        # --- Database Saving ---
        saved = 0
        # Use a transaction to ensure all unique trends are saved, or none are (atomicity)
        with transaction.atomic():
            for tdata in unique_trends:
                # Attempt to update an existing trend (based on season and keywords) or create a new one
                obj, created = Trend.objects.update_or_create(
                    season=season,
                    keywords=tdata["keywords"],
                    defaults={
                        "popularity_score": float(tdata.get("popularity_score", 0.0)),
                        "category": category,
                        "source_url": tdata.get("source_url", ""),
                        "source_name": tdata.get("source_name"), # Use the source_name from the trend data
                    },
                )
                if created:
                    saved += 1

        self.stdout.write(self.style.SUCCESS(f"Saved {saved} new unique trends."))

        # --- Post-Processing Task ---
        # Call the function to process/analyze the newly saved trends (e.g., set 'hot' status)
        result = compute_hot_trends(season)
        self.stdout.write(self.style.SUCCESS(result))


    # --- Deduplication Helper Method ---
    def _deduplicate_trends(self, trends):
        """Remove duplicates based on keyword similarity using SequenceMatcher."""
        unique = []
        seen = set() # Stores the keywords (lowercase) of trends already added to 'unique'
        for trend in trends:
            keywords_lower = trend.get("keywords_lower", trend["keywords"].lower())
            is_duplicate = False
            # Check the current trend against all previously accepted unique trends
            for existing in seen:
                # Calculate the ratio of similarity between the two keyword strings
                similarity = SequenceMatcher(None, keywords_lower, existing).ratio()
                if similarity > 0.8:  # If the ratio exceeds the threshold (80% similarity), it's a duplicate
                    is_duplicate = True
                    break
            if not is_duplicate:
                unique.append(trend)
                seen.add(keywords_lower) # Add the new unique trend's keywords to the 'seen' set
        return unique