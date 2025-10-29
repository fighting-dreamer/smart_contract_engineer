## Contract Deployment Method Comparison: CREATE vs. CREATE2

| Feature | `CREATE` (Standard Deployment) | `CREATE2` (Deterministic Deployment) |
| :--- | :--- | :--- |
| **Address Derivation** | Sender Address + **Nonce** (Transaction Count) | Deployer Address + **Salt** + **Bytecode Hash** |
| **Key Input** | The deployer's **Nonce** is the critical factor. | The **Salt** is the critical factor. |
| **Address Predictability** | **Non-deterministic.** The address changes with every transaction the sender makes. | **Deterministic.** The address is always the same, given the same inputs. |
| **Does it use Salt?** | ❌ No. | ✅ Yes, a 32-byte custom value is required. |

💡 Quick Note on the Difference
The key takeaway is that the Nonce is state-dependent (it changes), which is why CREATE is non-deterministic. The Salt is a fixed, user-chosen input, which is why CREATE2 is deterministic and allows for off-chain precomputation.