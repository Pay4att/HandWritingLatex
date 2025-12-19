import { Plugin } from "obsidian";
import { startInsertServer } from "./insert-server";

const INSERT_HOST = "127.0.0.1";
const INSERT_PORT = 27123;

export default class FormulaInsertPlugin extends Plugin {
	private stopServer: (() => void) | null = null;

	async onload() {
		this.stopServer = startInsertServer(this.app, {
			host: INSERT_HOST,
			port: INSERT_PORT,
		});
	}

	onunload() {
		if (this.stopServer) {
			this.stopServer();
			this.stopServer = null;
		}
	}
}
