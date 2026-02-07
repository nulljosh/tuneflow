const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Cyberpunk neon city background
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#0a0a1f');
bgGradient.addColorStop(0.5, '#1a0033');
bgGradient.addColorStop(1, '#0a0a1f');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Vertical neon strips
ctx.fillStyle = 'rgba(0, 255, 255, 0.3)';
for (let x = 0; x < width; x += 200) {
    const stripWidth = 30 + Math.random() * 20;
    ctx.fillRect(x, 0, stripWidth, height);
}

ctx.fillStyle = 'rgba(255, 0, 255, 0.2)';
for (let x = 100; x < width; x += 200) {
    const stripWidth = 20 + Math.random() * 15;
    ctx.fillRect(x, 0, stripWidth, height);
}

// Horizontal scan lines
ctx.fillStyle = 'rgba(0, 255, 255, 0.1)';
for (let y = 0; y < height; y += 50) {
    ctx.fillRect(0, y, width, 2);
}

// Glitch rectangles
ctx.fillStyle = 'rgba(255, 0, 255, 0.4)';
for (let i = 0; i < 15; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const w = Math.random() * 200 + 50;
    const h = Math.random() * 30 + 10;
    ctx.fillRect(x, y, w, h);
}

// Neon colors
const colors = ['#00ffff', '#ff00ff', '#00ff00', '#ffff00'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Chromatic aberration
        ctx.fillStyle = 'rgba(255, 0, 255, 0.5)';
        ctx.fillText(char, xPos - 5, yPos);
        ctx.fillStyle = 'rgba(0, 255, 255, 0.5)';
        ctx.fillText(char, xPos + 5, yPos);
        
        // Black outline
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 8;
        ctx.strokeText(char, xPos, yPos);
        
        // Neon glow
        ctx.shadowBlur = 60;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        
        // Extra glow layer
        ctx.shadowBlur = 30;
        ctx.fillText(char, xPos, yPos);
        
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText("75 &", height / 2 - 100, 200);
drawText("UNSTOPPABLE", height / 2 + 120, 180);

// Digital particles
ctx.fillStyle = 'rgba(0, 255, 255, 0.8)';
for (let i = 0; i < 100; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const size = Math.random() * 3 + 1;
    ctx.fillRect(x, y, size, size);
}

ctx.fillStyle = 'rgba(255, 0, 255, 0.8)';
for (let i = 0; i < 100; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const size = Math.random() * 3 + 1;
    ctx.fillRect(x, y, size, size);
}

// Scanlines overlay
ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
for (let y = 0; y < height; y += 4) {
    ctx.fillRect(0, y, width, 2);
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-cyberpunk.png', buffer);
console.log('Cyberpunk birthday saved!');
