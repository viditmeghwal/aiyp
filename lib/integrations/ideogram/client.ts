const IDEOGRAM_API_URL = "https://api.ideogram.ai";

interface IdeogramGenerateParams {
  prompt: string;
  model?: "V_2" | "V_2_TURBO";
  resolution?: string;
  style_type?: "REALISTIC" | "DESIGN" | "GENERAL" | "RENDER_3D" | "ANIME";
}

export async function generateImage(params: IdeogramGenerateParams): Promise<{ url: string }[]> {
  const response = await fetch(`${IDEOGRAM_API_URL}/generate`, {
    method: "POST",
    headers: { "Api-Key": process.env.IDEOGRAM_API_KEY!, "Content-Type": "application/json" },
    body: JSON.stringify({
      image_request: {
        prompt: params.prompt,
        model: params.model ?? "V_2",
        resolution: params.resolution ?? "RESOLUTION_1024_1024",
        style_type: params.style_type ?? "DESIGN",
      },
    }),
  });
  if (!response.ok) throw new Error(`Ideogram API error: ${response.statusText}`);
  const data = await response.json() as { data: { url: string }[] };
  return data.data;
}
