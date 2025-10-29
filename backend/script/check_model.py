"""Check which Ollama models are available."""
import requests

print("\n" + "="*60)
print("CHECKING AVAILABLE OLLAMA MODELS")
print("="*60)

try:
    response = requests.get("http://localhost:11434/api/tags", timeout=5)
    if response.status_code == 200:
        data = response.json()
        models = data.get('models', [])
        
        if models:
            print(f"\n✅ Found {len(models)} model(s):")
            for model in models:
                name = model.get('name', 'Unknown')
                size = model.get('size', 0) / (1024**3)  # Convert to GB
                print(f"   - {name} ({size:.2f} GB)")
                
            # Check if stockwise-model exists
            model_names = [m.get('name', '') for m in models]
            if 'stockwise-model:latest' in model_names or 'stockwise-model' in model_names:
                print("\n✅ 'stockwise-model' is available!")
            else:
                print("\n⚠️  'stockwise-model' NOT found!")
                print("   Available models:", ', '.join(model_names))
                print("\n   You need to either:")
                print("   1. Create stockwise-model: ollama create stockwise-model -f Modelfile")
                print("   2. Or use an existing model in settings.py")
        else:
            print("\n⚠️  No models found!")
            print("   Pull a model with: ollama pull llama3.2")
    else:
        print(f"❌ Error: {response.status_code}")
        print(response.text[:200])
        
except requests.exceptions.ConnectionError:
    print("\n❌ Cannot connect to Ollama!")
    print("   Make sure Ollama is running")
except Exception as e:
    print(f"\n❌ Error: {e}")

print("\n" + "="*60)
