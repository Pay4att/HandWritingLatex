import { App, MarkdownView } from "obsidian";
import { createServer, IncomingMessage, ServerResponse } from "http";

interface InsertServerOptions {
	host: string;
	port: number;
}

interface InsertPayload {
	latex?: unknown;
}

export function startInsertServer(app: App, options: InsertServerOptions): () => void {
	const server = createServer(async (req, res) => {
		if (req.method !== "POST") {
			respondNotFound(res);
			return;
		}

		const path = getPath(req, options);
		if (path !== "/insert") {
			respondNotFound(res);
			return;
		}

		let rawBody = "";
		try {
			rawBody = await readBody(req);
		} catch {
			respondJson(res, 400, { error: "Failed to read request body" });
			return;
		}
		if (!rawBody) {
			respondNoContent(res);
			return;
		}

		let payload: InsertPayload;
		try {
			payload = JSON.parse(rawBody) as InsertPayload;
		} catch {
			respondJson(res, 400, { error: "Invalid JSON body" });
			return;
		}

		const latex = normalizeLatex(payload.latex);
		if (!latex) {
			respondNoContent(res);
			return;
		}

		const editor = getActiveEditor(app);
		if (!editor) {
			respondJson(res, 409, { error: "No active editor" });
			return;
		}

		editor.replaceSelection(latex);
		respondJson(res, 200, { ok: true });
	});

	server.on("error", (error) => {
		console.error("[Formula OCR] insert server error", error);
	});

	server.listen(options.port, options.host);

	return () => server.close();
}

function getActiveEditor(app: App) {
	const view = app.workspace.getActiveViewOfType(MarkdownView);
	return view?.editor ?? null;
}

function normalizeLatex(value: unknown): string {
	if (typeof value !== "string") {
		return "";
	}

	const trimmed = value.trim();
	if (!trimmed) {
		return "";
	}

	if (trimmed.startsWith("$") && trimmed.endsWith("$")) {
		return trimmed;
	}

	return `$$\n${trimmed}\n$$`;
}

function getPath(req: IncomingMessage, options: InsertServerOptions): string {
	const url = new URL(req.url ?? "/", `http://${options.host}:${options.port}`);
	return url.pathname;
}

function readBody(req: IncomingMessage): Promise<string> {
	return new Promise((resolve, reject) => {
		let data = "";
		req.setEncoding("utf8");
		req.on("data", (chunk) => {
			data += chunk;
		});
		req.on("end", () => resolve(data));
		req.on("error", reject);
	});
}

function respondJson(res: ServerResponse, status: number, payload: object): void {
	const body = JSON.stringify(payload);
	res.writeHead(status, {
		"Content-Type": "application/json",
		"Content-Length": Buffer.byteLength(body),
	});
	res.end(body);
}

function respondNotFound(res: ServerResponse): void {
	res.writeHead(404);
	res.end();
}

function respondNoContent(res: ServerResponse): void {
	res.writeHead(204);
	res.end();
}
