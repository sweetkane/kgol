# kgol - Kane's Game Of Life
An interactive twist on [Conway's Game Of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) developed for Apple devices

## Rules
Conway's Game Of Life is based on a couple simple rules:
- If a cell is alive, and it has less than 2, or more than 3 living neighbors, it dies
- If a cell is dead, and it has exactly 3 living neighbors, it comes to life

In Kane's game of life, we keep these rules, but we replace the numbers with variables
- If a cell is alive, and it has less than `alpha` or more than `beta` living neighbors, it dies
- If a cell is dead, and it has exactly `chi` living neighbors, it comes to life
- The user can adjust `alpha`, `beta`, and `chi` in real time to generate cool emergent patterns!
- A couple more tweaks:
  - If a cell is dead and has zero living neighbors, there's a small probability it comes to life
    - This lets the user keep things going even if you accidentally kill all the cells
  - Every cell gets a random color, whose temperature range is determined by how many living neighbors it has 

## Gallery
![ezgif-5-03c1abffae](https://github.com/user-attachments/assets/cb146ba7-894f-4cc0-a871-88ac6b421873)
![ezgif-5-8857c1f289](https://github.com/user-attachments/assets/28730ff2-a293-4879-bec6-a61200ac0e95)
![ezgif-5-d907c894af](https://github.com/user-attachments/assets/8a084dd5-aee0-47c9-9fa4-772ded074863)

## License

This project is licensed under the Apache License, Version 2.0. See the [LICENSE](LICENSE.txt) file for details.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
