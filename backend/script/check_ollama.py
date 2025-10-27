"""Check if Ollama is running and accessible."""
import requests

OLLAMA_API = "http://localhost:11434/api/generate"

print("\n" + "="*60)
print("CHECKING OLLAMA STATUS")
print("="*60)

try:
    # Try to connect to Ollama
    response = requests.get("http://localhost:11434/", timeout=5)
    print("\n✅ Ollama is running!")
    print(f"   Status code: {response.status_code}")
    
    # Try a simple generation
    print("\n📤 Testing simple generation...")
    test_response = requests.post(
        OLLAMA_API,
        json={
            "model": "llama3.2:1b",
            "prompt": "Say 'Hello' in JSON format: {\"message\": \"...\"}",
            "stream": False
        },
        timeout=30
    )
    
    if test_response.status_code == 200:
        data = test_response.json()
        print("✅ Ollama responded successfully!")
        print(f"   Response: {data.get('response', '')[:200]}")
    else:
        print(f"❌ Ollama returned error: {test_response.status_code}")
        print(f"   {test_response.text[:200]}")
        
except requests.exceptions.ConnectionError:
    print("\n❌ Ollama is NOT running!")
    print("   Start Ollama with: ollama serve")
    print("   Or on Windows: Start the Ollama application")
except requests.exceptions.Timeout:
    print("\n❌ Ollama connection timed out")
except Exception as e:
    print(f"\n❌ Error: {e}")

print("\n" + "="*60)
