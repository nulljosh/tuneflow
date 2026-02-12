const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Dark gradient background
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#000000');
bgGradient.addColorStop(0.5, '#1a0033');
bgGradient.addColorStop(1, '#000000');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Pixel grid effect
ctx.strokeStyle = 'rgba(0, 255, 0, 0.1)';
ctx.lineWidth = 1;
for (let x = 0; x < width; x += 20) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
    ctx.stroke();
}
for (let y = 0; y < height; y += 20) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(width, y);
    ctx.stroke();
}

// Arcade colors - neon green/cyan
const colors = ['#00ff00', '#00ff88', '#00ffff'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Glow
        ctx.shadowBlur = 50;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        
        // Pixelated shadow
        ctx.shadowBlur = 0;
        ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
        ctx.fillText(char, xPos + 8, yPos + 8);
        
        // Main text
        ctx.shadowBlur = 40;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText('HAPPY BIRTHDAY', height / 2 - 80, 120);
drawText('GRANDMA', height / 2 + 100, 180);

// Scanlines
ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
for (let y = 0; y < height; y += 4) {
    ctx.fillRect(0, y, width, 2);
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/80s-arcade-birthday.png', buffer);
console.log('Arcade birthday saved');
