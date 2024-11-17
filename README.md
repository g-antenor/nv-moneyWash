# 💵 Money Washing

Simple script for money laundering, used to convert dirty cash into clean money, linking the cash to the machine where it was laundered. Any player can claim the amount with adjustable deductions.

---

## ⚙️ Dependências

Script developed for `QBCore`, compatible with some `OX` resources. 
Check the compatible dependencies below:
- **Dependencies**:
  - `ox_lib`
  - `ox_doorlock`
  - `qb-inventory` or `ox_inventory`
  - `qb-target` or `ox_target`

---

## 🚀 Instalação

Follow the steps below to install and configure the script:

1. Clone the repository:
   ```bash
   git clone https://github.com/g-antenor/nv-moneyWash.git
   ```
2. Add the script to your `server.cfg`:
    ```bash
    ensure nv-moneyWash
    ```
3. In your `database`, run the `.sql file` to create the table.

4. Modify `config.lua` according to your needs, then start the server.