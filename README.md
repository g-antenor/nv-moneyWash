# 💵 Money Washing

Simple script for money laundering, used to convert dirty cash into clean money, linking the cash to the machine where it was laundered. Any player can claim the amount with adjustable deductions.

**The script offers two formats**: `Safe Mode` and `PvP Mode`

## ⚙️ Dependências

Script developed for `QBCore`, compatible with some `OX` resources. 
Check the compatible dependencies below:
- **Dependencies**:
  - [`ox_lib`](https://github.com/overextended/ox_lib)
  - [`qb-inventory`](https://github.com/qbcore-framework/qb-inventory) or [`ox_inventory`](https://github.com/overextended/ox_inventory)
  - [`qb-target`](https://github.com/qbcore-framework/qb-target) or [`ox_target`](https://github.com/overextended/ox_target)

<br>
<br>

>If you want to support, you can buy me a coffee: </br>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D81650V6)


<br>
<br>

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
3. In the `installation` folder, you will find item resources for running the script:
    - **ox_inventory**:
        - **Items**: Copy all items from `installation/ox_inventory` and paste them into `ox_inventory/data/items`.
        - **Images**: Copy all images from `installation/images` and paste them into `ox_inventory/web/images`.

    - **qb-inventory**:
        - **Items**: Copy all items from `installation/ox_inventory` and paste them into `qb-core/shared/items`.
        - **Images**: Copy all images from `installation/images` and paste them into `qb-inventory/html/images`.

4. In your `database`, run the `.sql file` to create the table.

5. Modify `config.lua` according to your needs, then start the server.
