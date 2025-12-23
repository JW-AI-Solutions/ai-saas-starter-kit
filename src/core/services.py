"""
DGX API Client - Reusable service for communicating with DGX Spark inference server.
"""
import httpx
from django.conf import settings
from typing import Optional, Dict, Any


class DGXClient:
    """Client for DGX Spark inference API."""
    
    def __init__(self):
        self.base_url = settings.DGX_API_URL
        self.api_key = settings.DGX_API_KEY
        self.timeout = 30.0
    
    def _get_headers(self) -> Dict[str, str]:
        """Get request headers with API key if configured."""
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers
    
    def health_check(self) -> Dict[str, Any]:
        """Check if DGX inference server is online."""
        try:
            with httpx.Client(timeout=5.0) as client:
                response = client.get(
                    f"{self.base_url}/health",
                    headers=self._get_headers()
                )
                response.raise_for_status()
                return {"status": "online", "data": response.json()}
        except Exception as e:
            return {"status": "offline", "error": str(e)}
    
    def inference(
        self, 
        prompt: str, 
        model: str = "llama3",
        max_tokens: int = 2048,
        temperature: float = 0.7
    ) -> Dict[str, Any]:
        """
        Send inference request to DGX.
        
        Args:
            prompt: The text prompt to send
            model: Model name (default: llama3)
            max_tokens: Maximum tokens to generate
            temperature: Sampling temperature
            
        Returns:
            Dict with 'response' and 'inference_time' or 'error'
        """
        try:
            with httpx.Client(timeout=self.timeout) as client:
                response = client.post(
                    f"{self.base_url}/inference",
                    headers=self._get_headers(),
                    json={
                        "prompt": prompt,
                        "model": model,
                        "max_tokens": max_tokens,
                        "temperature": temperature
                    }
                )
                response.raise_for_status()
                return response.json()
        except httpx.TimeoutException:
            return {"error": "DGX request timed out"}
        except httpx.HTTPError as e:
            return {"error": f"DGX API error: {str(e)}"}
        except Exception as e:
            return {"error": f"Unexpected error: {str(e)}"}


# Singleton instance
dgx_client = DGXClient()
