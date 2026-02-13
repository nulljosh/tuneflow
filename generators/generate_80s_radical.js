const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Hot pink/yellow gradient
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#ff006e');
bgGradient.addColorStop(0.5, '#ffbe0b');
bgGradient.addColorStop(1, '#fb5607');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Diagonal stripes
ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
ctx.lineWidth = 40;
for (let i = -height; i < width + height; i += 100) {
    ctx.beginPath();
    ctx.moveTo(i, 0);
    ctx.lineTo(i + height, height);
    ctx.stroke();
}

// Sun rays from corner
ctx.strokeStyle = 'rgba(255, 255, 0, 0.3)';
ctx.lineWidth = 20;
for (let angle = 0; angle < Math.PI / 2; angle += 0.1) {
    ctx.beginPath();
    ctx.moveTo(0, height);
    const x = Math.cos(angle) * 2000;
    const y = height - Math.sin(angle) * 2000;
    ctx.lineTo(x, y);
    ctx.stroke();
}

const colors = ['#ffffff', '#00ffff', '#ff00ff', '#ffff00'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        // Multi-color outline
        ctx.strokeStyle = 'rgba(0, 0, 0, 0.8)';
        ctx.lineWidth = 12;
        ctx.strokeText(char, xPos, yPos);
        
        // Glow
        ctx.shadowBlur = 40;
        ctx.shadowColor = colors[i % colors.length];
        ctx.fillStyle = colors[i % colors.length];
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText('HAPPY BIRTHDAY', height / 2 - 120, 150);
drawText('GRANDMA!', height / 2 + 80, 200);

// Add some stars/sparkles
ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
for (let i = 0; i < 50; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const size = Math.random() * 4 + 2;
    
    // Star shape
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(Math.random() * Math.PI);
    ctx.beginPath();
    ctx.moveTo(0, -size);
    ctx.lineTo(size/3, 0);
    ctx.lineTo(size, 0);
    ctx.lineTo(size/3, size/3);
    ctx.lineTo(size/2, size);
    ctx.lineTo(0, size/2);
    ctx.lineTo(-size/2, size);
    ctx.lineTo(-size/3, size/3);
    ctx.lineTo(-size, 0);
    ctx.lineTo(-size/3, 0);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/80s-radical-birthday.png', buffer);
console.log('Radical birthday saved');
