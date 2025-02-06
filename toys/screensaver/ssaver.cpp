
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <locale.h>
#include <ncurses.h>
#include <unistd.h>

#define MAP_WIDTH 30
#define MAP_HEIGHT 30
#define FRAME_TIME 25000
#define ROTATION_STEPS 10
#define ROTATION_INCREMENT (M_PI / 2.0 / ROTATION_STEPS)

const float anticipation_distance = 6.0f;
const float speed = 0.1f;

char worldMap[MAP_HEIGHT][MAP_WIDTH];

float playerX = 3.0, playerY = 3.0;
float dirX = 1.0, dirY = 0.0;
float angle = 0.0;
int rotating = 0;
int rotationProgress = 0;

bool isWall(float x, float y) {
  int mapX = static_cast<int>(x);
  int mapY = static_cast<int>(y);

  if (mapX < 0 || mapX >= MAP_WIDTH || mapY < 0 || mapY >= MAP_HEIGHT) {
    return true;
  }

  return worldMap[mapY][mapX] == '1';
}

void getScreenSize(int &screenHeight, int &screenWidth) {
  getmaxyx(stdscr, screenHeight, screenWidth);
}

void generateMap() {
  for (int y = 0; y < MAP_HEIGHT; y++) {
    for (int x = 0; x < MAP_WIDTH; x++) {
      worldMap[y][x] = '0';
    }
  }

  for (int x = 0; x < MAP_WIDTH; x++) {
    worldMap[0][x] = '1';
    worldMap[MAP_HEIGHT - 1][x] = '1';
  }
  for (int y = 0; y < MAP_HEIGHT; y++) {
    worldMap[y][0] = '1';
    worldMap[y][MAP_WIDTH - 1] = '1';
  }

  int numWalls = 15 + rand() % 10;

  for (int i = 0; i < numWalls; i++) {
    int wallLength = 2 + rand() % 7;
    int startX, startY, direction;
    bool validPlacement = false;

    while (!validPlacement) {
      startX = 2 + rand() % (MAP_WIDTH - 4);
      startY = 2 + rand() % (MAP_HEIGHT - 4);
      direction = rand() % 2;

      validPlacement = true;
      for (int j = -2; j < wallLength + 2; j++) {
        int checkX = (direction == 0) ? startX + j : startX;
        int checkY = (direction == 1) ? startY + j : startY;

        if (checkX < 1 || checkX >= MAP_WIDTH - 1 || checkY < 1 ||
            checkY >= MAP_HEIGHT - 1) {
          continue;
        }

        if (worldMap[checkY][checkX] == '1') {
          validPlacement = false;
          break;
        }
      }
    }

    for (int j = 0; j < wallLength; j++) {
      int x = (direction == 0) ? startX + j : startX;
      int y = (direction == 1) ? startY + j : startY;

      if (x >= 1 && x < MAP_WIDTH - 1 && y >= 1 && y < MAP_HEIGHT - 1) {
        worldMap[y][x] = '1';
      }
    }
  }

  playerX = 3.0;
  playerY = 3.0;
  while (isWall(playerX, playerY)) {
    playerX = 2 + rand() % (MAP_WIDTH - 4);
    playerY = 2 + rand() % (MAP_HEIGHT - 4);
  }
}

void rotatePlayer() {
  if (rotating != 0) {
    angle += rotating * ROTATION_INCREMENT;
    dirX = cos(angle);
    dirY = sin(angle);
    rotationProgress++;

    if (rotationProgress >= ROTATION_STEPS) {
      rotating = 0;
      rotationProgress = 0;
    }
  }
}

void updateMovement() {
  if (rotating) {
    rotatePlayer();
    return;
  }

  float futureX = playerX + dirX * anticipation_distance * speed;
  float futureY = playerY + dirY * anticipation_distance * speed;

  if (isWall(futureX, futureY)) {
    rotating = (rand() % 2 == 0) ? 1 : -1;
  } else {
    playerX += dirX * speed;
    playerY += dirY * speed;
  }
}

void render3D(int screenHeight, int screenWidth) {
  const wchar_t *shadingA = L"░▒▓█";

  const wchar_t *shadingB = L"▁▂▃▄▅▆▇";

  const wchar_t *shadingC = L"⠀⠁⠂⠄⡀⢀⠈⠃⠅⠆⡂⢂⠠⠑⠒⡄⢄⣀⠉⠋⠍⠎⡉⢉⠡⠣⠥⠦⡐⢐⠤⠱⠲⡘⢘⡌⢌⣂⣄⠰⠹⠺⡙⢙⡜⢜⡢⢢⣌"
                            L"⢌⣅⣆⠼⠽⠾⡝⢝⡞⢞⡤⢤⣕⢕⣖⢖⡮⢮⡶⢶⣗⢗⣘⢘⡶⢶⡷⢷⡶⣶⢶⣷⢷⣾⣿";

  const wchar_t *shadingD = L".-':_,^=;><+!rc*/"
                            L"z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]"
                            L"2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@";

  for (int x = 0; x < screenWidth; x++) {
    float cameraX = 2.0f * x / screenWidth - 1.0f;
    float rayDirX = dirX + cameraX * -dirY;
    float rayDirY = dirY + cameraX * dirX;

    int mapX = static_cast<int>(playerX);
    int mapY = static_cast<int>(playerY);

    float deltaDistX = (rayDirX == 0) ? 1e30 : std::fabs(1 / rayDirX);
    float deltaDistY = (rayDirY == 0) ? 1e30 : std::fabs(1 / rayDirY);

    int stepX = (rayDirX < 0) ? -1 : 1;
    int stepY = (rayDirY < 0) ? -1 : 1;

    float sideDistX = (rayDirX < 0) ? (playerX - mapX) * deltaDistX
                                    : (mapX + 1.0 - playerX) * deltaDistX;
    float sideDistY = (rayDirY < 0) ? (playerY - mapY) * deltaDistY
                                    : (mapY + 1.0 - playerY) * deltaDistY;

    int hit = 0, side;

    while (!hit) {
      if (mapX < 0 || mapX >= MAP_WIDTH || mapY < 0 || mapY >= MAP_HEIGHT)
        break;

      if (sideDistX < sideDistY) {
        sideDistX += deltaDistX;
        mapX += stepX;
        side = 0;
      } else {
        sideDistY += deltaDistY;
        mapY += stepY;
        side = 1;
      }

      if (worldMap[mapY][mapX] == '1')
        hit = 1;
    }

    float perpWallDist = (side == 0)
                             ? (mapX - playerX + (1.0 - stepX) / 2.0) / rayDirX
                             : (mapY - playerY + (1.0 - stepY) / 2.0) / rayDirY;

    int lineHeight = static_cast<int>(screenHeight / perpWallDist);
    int drawStart = -lineHeight / 2 + screenHeight / 2;
    int drawEnd = lineHeight / 2 + screenHeight / 2;

    if (drawStart < 0) {
      drawStart = 0;
    }

    if (drawEnd >= screenHeight) {
      drawEnd = screenHeight - 1;
    }

    int maxIndex = (int)wcslen(shadingD) - 1;
    int shadeIndex = std::max(
        0, std::min(maxIndex,
                    (int)((lineHeight / (float)screenHeight) * maxIndex)));

    wchar_t shadeChar[2] = {shadingD[shadeIndex], L'\0'};

    const wchar_t ceilingChar = L' ';
    const wchar_t floorChar = L' ';

    for (int y = 0; y < screenHeight; y++) {
      if (y < drawStart) {
        // mvaddnwstr(y, x, &ceilingChar, 1);
      } else if (y >= drawStart && y <= drawEnd) {
        mvaddnwstr(y, x, shadeChar, 1);
      } else {
        // mvaddnwstr(y, x, &floorChar, 1);
      }
    }
  }
}

int main() {
  initscr();
  noecho();
  curs_set(0);
  timeout(0);
  nodelay(stdscr, TRUE);
  srand(time(0));

  generateMap();

  int screenHeight, screenWidth;

  while (true) {
    setlocale(LC_ALL, "");
    getScreenSize(screenHeight, screenWidth);
    updateMovement();
    clear();
    render3D(screenHeight, screenWidth);
    refresh();
    usleep(FRAME_TIME);
    if (getch() == 'q') {
      break;
    }
  }

  endwin();
  return 0;
}
