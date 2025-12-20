import { Plugin } from "obsidian";
import { startInsertServer } from "./insert-server";
import { startBonjourAdvertiser } from "./service-advertiser";

const INSERT_HOST = "0.0.0.0";
const INSERT_PORT = 27123;

export default class FormulaInsertPlugin extends Plugin {
	private stopServer: (() => void) | null = null;
	private stopAdvertiser: (() => void) | null = null;

	async onload() {
		this.stopServer = startInsertServer(this.app, {
			host: INSERT_HOST,
			port: INSERT_PORT,
		});
		this.stopAdvertiser = startBonjourAdvertiser(INSERT_PORT);
	}

	onunload() {
		if (this.stopServer) {
			this.stopServer();
			this.stopServer = null;
		}
		if (this.stopAdvertiser) {
			this.stopAdvertiser();
			this.stopAdvertiser = null;
		}
	}
}
