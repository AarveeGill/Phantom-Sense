# Contributing to Phantom Sense

Thanks for your interest. Phantom Sense is a small project and contributions of any size are welcome — from fixing a typo to adding a new feature.

## Reporting Bugs

Open an [issue](https://github.com/AarveeGill/Phantom-Sense/issues) and include:

- What you were doing (e.g. running the Deck installer, forwarding the DualSense).
- What you expected to happen.
- What actually happened (error messages, exit codes, screenshots if relevant).
- Your setup — SteamOS version, Windows version, network config (single/multi router, Tailscale).

Logs help. On the Deck: `sudo journalctl -u Phantom Sense --no-pager -n 50`. On Windows: copy the terminal output from the .bat installer.

## Suggesting Features

Open an issue with the label `enhancement`. Describe the use case — what problem it solves and who benefits.

## Submitting Code

1. Fork the repo.
2. Create a branch from `main` (`git checkout -b fix/your-description`).
3. Make your changes.
4. Test them. If you changed the Deck script, test on a Steam Deck. If you changed the PC script, test on Windows.
5. Open a pull request against `main`. Describe what changed and why.

Keep commits focused. One fix per PR when possible.

### Code style

- Bash: use `set -euo pipefail`, quote variables, use `[[ ]]` over `[ ]`.
- PowerShell: follow the existing patterns in `install-Phantom Sense-pc.ps1`.
- No emoji in scripts or docs.
- Comments should explain *why*, not *what*.

## Documentation

Improvements to the README, troubleshooting, FAQ, or setup instructions are always welcome. Same process — fork, branch, PR.

## Game Compatibility Reports

If you've tested a game that supports DualSense features (adaptive triggers, haptics) through Phantom Sense, open an issue or PR with:

- Game name.
- Whether adaptive triggers, haptics, gyro, and touchpad worked.
- Any quirks or required settings.

This will eventually feed into a game compatibility matrix.

## Areas Where Help Is Needed

From the [roadmap](README.md#roadmap):

- Decky Loader plugin for Game Mode integration.
- Wired vs. Wi-Fi latency benchmarks with proper methodology.
- Tailscale WAN configuration guide.
- Game compatibility testing and reports.
- Video walkthrough or demo.

## Code of Conduct

Be respectful. This is a hobby project built to solve a real problem. Constructive feedback is welcome; hostility is not.
