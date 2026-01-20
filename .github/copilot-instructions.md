Purpose
This repository contains the core Arbitrum bridge contracts and a Rust-based watcher.
The guidance below helps AI coding agents be immediately productive by highlighting the "why", key files, patterns, and how tests and signatures interoperate.

**Big Picture**
- **Contracts:** `Bridge2.sol` implements an Arbitrum -> L1 bridge (validator-set epochs, dispute periods, lockers/finalizers, batched withdrawals/deposits).
- **Signature helpers:** `Signature.sol` defines the `Agent` and `Signature` types and provides domain hashing + ECDSA recovery helpers used across the codebase.
- **Watchers/tests:** `tests/bridge_watcher2.rs` (and `tests/example.rs`) are Rust integration code that listens to bridge events and coordinates L1 actions.

**What matters for edits and PRs**
- Solidity pragma: `^0.8.9` — follow that compiler family when changing contract code.
- Contracts import OpenZeppelin and `@arbitrum/nitro-contracts` (ArbSys precompile). Ensure your toolchain can resolve those imports (Foundry/Hardhat/NPM remappings or monorepo symlinks).
- Tests in `tests/` are Rust files that rely on a larger infra (eth clients, tx batchers, staking helper types). They typically run as part of the Rust workspace that consumes these files — don't assume `cargo test` at this repo root will work unless run inside that workspace.

**Important code patterns (copyable examples)**
- Validator-set checkpoint: `makeValidatorSetHash(ValidatorSet)` — validators+powers+epoch are keccak-encoded and compared against stored checkpoints (`hotValidatorSetHash`, `coldValidatorSetHash`).
- Signature verification: `checkValidatorSignatures(message, activeSet, signatures, validatorSetHash)` expects signatures to be a subsequence matching the order of `activeSet.validators` and enforces >2/3 cumulative power.
- Dispute flow: updates are staged in `pendingValidatorSetUpdate` and finalized only after both time and block-based dispute checks (`getDisputePeriodErrorCode`) pass.
- Arb-specific block number: use `getCurBlockNumber()` which uses `ArbSys` precompile on Arbitrum and falls back to `block.number` for chain id 1337 (local tests).
- ERC20 Permit usage: `depositWithPermit` and `batchedDepositWithPermit` use `ERC20Permit` + `permit(...)` then `transferFrom`.

**Developer workflows & commands (examples — adapt to local toolchain)**
- Compile/check contracts: ensure solidity imports resolve. Example with Foundry-style tooling (replace with your setup):
  - `forge build` (ensure remappings for OpenZeppelin and Arbitrum contracts)
- Rust integration/watch tests: run from the Rust workspace that owns these tests:
  - `cargo test --test bridge_watcher2` (run from the workspace root that includes this crate)
- When running local nodes, note the code assumes `chainid == 1337` for local fallback behavior in `getCurBlockNumber()`.

**Project-specific conventions & gotchas**
- Signer ordering: signer list must be a subsequence of the active validator set and in the same order — do not re-order signatures before passing to contract APIs.
- Message uniqueness: many mutating functions call `checkMessageNotUsed(message)` — replay protection is enforced by `usedMessages` mapping; always compute `makeMessage(keccak(...))` exactly as in `Bridge2.sol` when producing signatures.
- Error signaling: contract uses emitted events (e.g., `FailedWithdrawal(bytes32 message, uint32 errorCode)`) to indicate failure modes instead of revert strings in some flows — watchers rely on these events.
- Epoch/power expectations: code comments assume ~20–30 validators; signature set sizes are expected to fit in a single transaction.

**Integration points**
- External libs: OpenZeppelin contracts; Arbitrum Nitro precompiles (`ArbSys`); ERC20Permit interface.
- Runtime infrastructure: the Rust watcher uses Etherscan tracking and a larger `infra` crate for wallet/chain abstractions — testing this file set outside that infra will require wiring those dependencies.

If any section is unclear or you want me to include concrete `forge`/`hardhat` remappings or a minimal `Cargo.toml` to run the Rust tests locally, tell me which toolchain you prefer and I will update the instructions.
