import random

def get_fallback_trends(season: str):
    """
    Returns a list of fallback fashion trends relevant to the given season.
    If the season isn't recognized, returns general timeless trends.
    """
    season = season.lower().strip()

    fallbacks_by_season = {
        "christmas": [
            "Festive knit sweaters and cozy jumpers",
            "Metallic and sequin party dresses",
            "Red and green color palettes",
            "Elegant winter coats with faux fur trims",
            "Velvet and satin evening wear",
            "Christmas pajamas and matching family outfits",
            "Holiday accessories: scarves, gloves, and berets",
            "Classy Christmas dinner outfits and sparkly heels",
            "Stylish giftable fashion sets and handbags",
            "Winter glam makeup and jewelry trends",
        ],
        "autumn": [
            "Chunky knit sweaters and scarves",
            "Brown, beige, and burnt orange color schemes",
            "Corduroy and flannel outfits",
            "Layered looks with trench coats",
            "Ankle boots and loafers for fall",
            "Plaid skirts and oversized sweaters",
            "Muted earth tones and leather jackets",
        ],
        "summer": [
            "Light linen shirts and dresses",
            "Floral prints and bright colors",
            "Beachwear and resort outfits",
            "Pastel accessories and open-toe sandals",
            "Flowy maxi dresses and sunglasses",
            "Tropical shirts and bucket hats",
        ],
        "spring": [
            "Floral dresses and skirts",
            "Pastel blazers and accessories",
            "Light denim and sneakers",
            "Flowy tops with floral accents",
            "Layered cardigans and spring scarves",
        ],
        "winter": [
            "Wool coats and turtlenecks",
            "Knitted beanies and gloves",
            "Monochrome winter layering",
            "Faux fur jackets and long boots",
            "Cashmere sweaters and tailored pants",
        ],
    }

    # Default generic fallbacks
    default_fallbacks = [
        "Timeless fashion staples",
        "Classic seasonal layering ideas",
        "Trending accessories for all-year style",
        "Neutral color palette inspirations",
        "Streetwear meets high fashion looks",
    ]

    return fallbacks_by_season.get(season, default_fallbacks)


def generate_fallback_entries(season: str, count: int = 5):
    """
    Generate fallback trend entries with randomized popularity scores.
    """
    trends = get_fallback_trends(season)
    random.shuffle(trends)
    selected = trends[:count]

    return [
        {
            "season": season,
            "keywords": f"{season} {text}",
            "popularity_score": round(random.uniform(65, 90), 1),
            "source_name": "Fallback",
            "source_url": "",
        }
        for text in selected
    ]
