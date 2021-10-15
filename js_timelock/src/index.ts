import * as timelock from './timelock.generated';
import * as hacl from '@smartpy/hacl-wasm';

const globalScope = typeof globalThis !== "undefined" ? globalThis : (typeof window !== "undefined" ? window : global);

hacl.getInitializedHaclModule().then(hacl => globalScope._HACL = hacl);

interface ChestAndChestKey {
    chest: string,
    key: string
}

/**
 * Verify if hacl-wasm is loaded, and wait for it to load if ecessary.
 *
 * @returns {Promise<void>}
 */
const ensureHaclWasmLoaded = async (): Promise<void> => {
    const milliseconds_per_try = 200;
    let wait_milliseconds = 5000;
    while (wait_milliseconds) {
        // if _HACL exists in the global context, it means that the wasm module is already loaded
        if (globalScope._HACL) return;
        // Wait a few milliseconds and check again
        wait_milliseconds -= milliseconds_per_try
        await new Promise(r => setTimeout(r, milliseconds_per_try));
    }
}

/**
 * Function which takes care of generating the locked value, the RSA parameters, and encrypt the payload.
 * Also returns the chest key.
 *
 * @param {string} payload The bytes to be locked
 * @param {number} time The time constant
 * @returns {ChestAndChestKey} The generated chest and chest_key
 */
const createChestAndChestKey = (payload: string, time: number): ChestAndChestKey => {
    return JSON.parse(timelock.create_chest_and_chest_key(payload, time));
}

/**
 * Function which unlock the value and create the time-lock proof.
 *
 * @param {string} chest Timelocked arbitrary bytes with the necessary public parameters to open it
 * @param {number} time The time constant
 * @returns {string} The generated chest_key
 */
const createChestKey = (chest: string, time: number): string => {
    return timelock.create_chest_key(chest, time);
}

/**
 * Tries to recover the underlying plaintext.
 *
 * @param {string} chest Timelocked arbitrary bytes with the necessary public parameters to open it
 * @param {string} chest_key The decryption key, alongside with a proof that the key is correct.
 * @param {number} time The time constant
 * @returns {JSON string} Result of the opening of a chest.
 *
 *  The opening can fail in two ways which we distinguish to blame the right party.
 *  One can provide a false unlocked_value or unlocked_proof, in which case
 *  we return [Bogus_opening] and the provider of the chest key is at fault.
 *  Othewise, one can lock the wrong key or put garbage in the ciphertext in which case
 *  we return [Bogus_cipher] and the provider of the chest is at fault.
 *  Otherwise we return [Correct payload] where [payload] is the content that had
 *  originally been put in the chest.
 */
const openChest = (chest: string, chest_key: string, time: number): string => {
    return timelock.open_chest(chest, chest_key, time);
}

const Timelock = {
    createChestAndChestKey,
    createChestKey,
    openChest,
    ensureHaclWasmLoaded
};

export default Timelock;
