const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Vaporwave gradient - purple to pink
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#0f0326');
bgGradient.addColorStop(0.3, '#2d1b4e');
bgGradient.addColorStop(0.6, '#8b2e8f');
bgGradient.addColorStop(1, '#f72585');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Draw sun
const sunRadius = 300;
const sunGradient = ctx.createRadialGradient(width / 2, height / 2 + 100, 0, width / 2, height / 2 + 100, sunRadius);
sunGradient.addColorStop(0, '#ffd60a');
sunGradient.addColorStop(0.4, '#ff006e');
sunGradient.addColorStop(1, 'rgba(255, 0, 110, 0)');
ctx.fillStyle = sunGradient;
ctx.beginPath();
ctx.arc(width / 2, height / 2 + 100, sunRadius, 0, Math.PI * 2);
ctx.fill();

// Sun stripes
ctx.fillStyle = 'rgba(15, 3, 38, 0.8)';
for (let y = height / 2 + 100 - sunRadius; y < height / 2 + 100 + sunRadius; y += 30) {
    ctx.fillRect(width / 2 - sunRadius, y, sunRadius * 2, 15);
}

// Perspective grid
const gridStart = height / 2 + 200;
const gridSpacing = 60;

ctx.strokeStyle = 'rgba(255, 0, 255, 0.8)';
ctx.lineWidth = 3;

// Horizontal lines with perspective
for (let y = gridStart; y < height; y += gridSpacing) {
    const progress = (y - gridStart) / (height - gridStart);
    const offset = 600 * progress;
    ctx.beginPath();
    ctx.moveTo(offset, y);
    ctx.lineTo(width - offset, y);
    ctx.stroke();
}

// Vertical lines
ctx.strokeStyle = 'rgba(0, 255, 255, 0.8)';
const numLines = 20;
for (let i = 0; i <= numLines; i++) {
    const x = (width / numLines) * i;
    const centerX = width / 2;
    const offset = (x - centerX) * 0.5;
    ctx.beginPath();
    ctx.moveTo(x, gridStart);
    ctx.lineTo(centerX + offset * 3, height);
    ctx.stroke();
}

// Text
const colors = ['#ff00ff', '#00ffff'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Chromatic aberration effect
        ctx.fillStyle = 'rgba(255, 0, 255, 0.5)';
        ctx.fillText(char, xPos - 4, yPos);
        ctx.fillStyle = 'rgba(0, 255, 255, 0.5)';
        ctx.fillText(char, xPos + 4, yPos);
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
        ctx.fillText(char, xPos + 6, yPos + 6);
        
        // Glow
        ctx.shadowBlur = 40;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText('HAPPY BIRTHDAY', 150, 110);
drawText('GRANDMA', 280, 140);

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/80s-retrowave-birthday.png', buffer);
console.log('Retro Wave birthday saved');
