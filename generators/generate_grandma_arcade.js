const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Retro arcade background - black with pixel grid
ctx.fillStyle = '#000000';
ctx.fillRect(0, 0, width, height);

// CRT screen glow
const glowGradient = ctx.createRadialGradient(width/2, height/2, 0, width/2, height/2, height/1.5);
glowGradient.addColorStop(0, 'rgba(0, 255, 0, 0.2)');
glowGradient.addColorStop(1, 'rgba(0, 0, 0, 0)');
ctx.fillStyle = glowGradient;
ctx.fillRect(0, 0, width, height);

// Arcade border
ctx.strokeStyle = '#00ff00';
ctx.lineWidth = 15;
ctx.strokeRect(100, 100, width - 200, height - 200);

ctx.strokeStyle = '#ffff00';
ctx.lineWidth = 8;
ctx.strokeRect(110, 110, width - 220, height - 220);

function drawPixelText(text, yPos, fontSize, color) {
    ctx.font = `bold ${fontSize}px "Courier New", monospace`;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'center';
    
    // Shadow
    ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
    ctx.fillText(text, width/2 + 4, yPos + 4);
    
    // Glow
    ctx.shadowBlur = 30;
    ctx.shadowColor = color;
    ctx.fillStyle = color;
    ctx.fillText(text, width/2, yPos);
    ctx.shadowBlur = 0;
}

drawPixelText('HIGH SCORE', 250, 80, '#ff00ff');
drawPixelText('═══════════════════════════', 320, 60, '#00ffff');
drawPixelText('GRANDMA', 430, 120, '#ffff00');
drawPixelText('75 YEARS', 570, 100, '#00ff00');
drawPixelText('NEW RECORD!', 690, 90, '#ff0000');
drawPixelText('═══════════════════════════', 770, 60, '#00ffff');
drawPixelText('INSERT COIN TO CONTINUE', 880, 50, '#ff00ff');

// Pixel decorations
const colors = ['#00ff00', '#ffff00', '#ff00ff', '#00ffff'];
for (let i = 0; i < 20; i++) {
    const x = 200 + Math.random() * (width - 400);
    const y = 150 + Math.random() * 100;
    const size = 10;
    ctx.fillStyle = colors[Math.floor(Math.random() * colors.length)];
    ctx.fillRect(x, y, size, size);
}

for (let i = 0; i < 20; i++) {
    const x = 200 + Math.random() * (width - 400);
    const y = height - 250 + Math.random() * 100;
    const size = 10;
    ctx.fillStyle = colors[Math.floor(Math.random() * colors.length)];
    ctx.fillRect(x, y, size, size);
}

// Scanlines
ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
for (let y = 0; y < height; y += 4) {
    ctx.fillRect(0, y, width, 2);
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-arcade.png', buffer);
console.log('Arcade saved!');
