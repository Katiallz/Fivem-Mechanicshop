import { writable, type Writable } from "svelte/store";

export const show: Writable<boolean> = writable(false);