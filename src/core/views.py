from django.shortcuts import render
from django.views.decorators.http import require_http_methods
from core.services import dgx_client
import time
import random

def home(request):
    """Main dashboard view."""
    return render(request, 'index.html')

@require_http_methods(["POST"])
def inference_demo(request):
    """HTMX endpoint that simulates AI inference."""
    prompt = request.POST.get('prompt', 'No prompt provided')
    
    # Simulate processing time
    # time.sleep(1.5)
    
    # Simulated responses
    # responses = [
    #     "A vector database stores data as high-dimensional vectors, enabling semantic similarity search.",
    #     "Vector databases use embeddings to enable 'fuzzy' matching based on meaning, not just keywords.",
    #     "Think of a vector database like a GPS for meaning - finding locations closest to your query in semantic space."
    # ]
    result = dgx_client.inference(prompt=prompt)

    if "error" in result:
        return render(request, 'partials/demo_result.html', {
            'prompt': prompt,
            'response': f"Error: {result['error']}"
        })
    
    return render(request, 'partials/demo_result.html', {
        'prompt': prompt,
        'response': result.get('response', 'No response received')
    })