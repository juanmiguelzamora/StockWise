from datetime import datetime

def get_current_season(date: datetime = None) -> str:
    """Return a season name based on month/day. Can be expanded with locale/event rules."""
    today = date or datetime.now()
    m = today.month
    if m in (12, 1, 2):
        return "Christmas"
    if m in (3, 4, 5):
        return "Spring"
    if m in (6, 7, 8):
        return "Summer"
    if m in (9, 10, 11):
        return "Autumn"
    return "General"