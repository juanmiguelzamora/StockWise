from django.core.management.base import BaseCommand
from trend_app.services.scraper import scrape_trending_clothes

class Command(BaseCommand):
    help = "Scrape trending clothing items (Google Trends) and save them into the database"

    def add_arguments(self, parser):
        parser.add_argument(
            "--subset-size",
            type=int,
            default=2,
            help="Number of seed keywords to scrape this run (default: 2).",
        )

    def handle(self, *args, **options):
        subset_size = options["subset_size"]

        self.stdout.write(f"🔎 Scraping {subset_size} trending keyword(s) from Google Trends...")
        items = scrape_trending_clothes(subset_size=subset_size)

        if items:
            self.stdout.write(self.style.SUCCESS(f"Done. Inserted/updated {len(items)} trends."))
        else:
            self.stdout.write(self.style.WARNING("No new trends found this run."))
