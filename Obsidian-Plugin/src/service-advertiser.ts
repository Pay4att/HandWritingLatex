import { Bonjour } from "bonjour-service";
import os from "os";

const SERVICE_TYPE = "formula-ocr";

export function startBonjourAdvertiser(port: number): () => void {
	const bonjour = new Bonjour();
	const name = os.hostname();
	const service = bonjour.publish({
		name,
		type: SERVICE_TYPE,
		protocol: "tcp",
		port,
		txt: {
			device: name,
		},
	});

	service.on("error", (error) => {
		console.error("[Formula OCR] bonjour error", error);
	});

	return () => {
		service.stop?.(() => bonjour.destroy());
	};
}
