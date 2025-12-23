from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import time
from typing import Optional

app = FastAPI(
    title="DGX Inference API",
    description="FastAPI server for AI inference on NVIDIA DGX Spark",
    version="1.0.0"
)

class InferenceRequest(BaseModel):
    prompt: str
    model: str = "llama3"
    max_tokens: int = 2048
    temperature: float = 0.7

class InferenceResponse(BaseModel):
    response: str
    model: str
    inference_time: float

@app.get("/")
async def root():
    """Root endpoint - API information."""
    return {
        "status": "online",
        "message": "DGX Inference Server",
        "version": "1.0.0",
        "available_models": ["llama3", "mistral"],
        "endpoints": {
            "health": "/health",
            "inference": "/inference",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring."""
    return {
        "status": "healthy",
        "gpu": "NVIDIA GB10",
        "service": "dgx-inference-api"
    }

@app.post("/inference", response_model=InferenceResponse)
async def inference(request: InferenceRequest):
    """
    Main inference endpoint.
    
    Currently configured for Ollama (localhost:11434).
    Update the URL below to point to your NIM containers when ready.
    """
    start_time = time.time()
    
    try:
        # TODO: Update this URL when you deploy NIMs
        # For now, it expects Ollama running on the host
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "http://host.docker.internal:11434/api/generate",
                json={
                    "model": request.model,
                    "prompt": request.prompt,
                    "stream": False,
                    "options": {
                        "temperature": request.temperature,
                        "num_predict": request.max_tokens
                    }
                }
            )
            response.raise_for_status()
            data = response.json()
            
            inference_time = time.time() - start_time
            
            return InferenceResponse(
                response=data.get("response", ""),
                model=request.model,
                inference_time=round(inference_time, 2)
            )
    
    except httpx.TimeoutException:
        raise HTTPException(
            status_code=504,
            detail="Inference request timed out after 30 seconds"
        )
    except httpx.HTTPError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Inference failed: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
