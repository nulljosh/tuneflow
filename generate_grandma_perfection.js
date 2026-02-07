const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Elegant gold/burgundy gradient
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#2d0a0a');
bgGradient.addColorStop(0.5, '#5c1a1a');
bgGradient.addColorStop(1, '#2d0a0a');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Art deco pattern
ctx.strokeStyle = 'rgba(212, 175, 55, 0.2)';
ctx.lineWidth = 2;
for (let y = 0; y < height; y += 60) {
    for (let x = 0; x < width; x += 60) {
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x + 30, y + 30);
        ctx.lineTo(x, y + 60);
        ctx.lineTo(x - 30, y + 30);
        ctx.closePath();
        ctx.stroke();
    }
}

// Gold ornate frame
ctx.strokeStyle = '#d4af37';
ctx.lineWidth = 20;
ctx.strokeRect(150, 150, width - 300, height - 300);

ctx.strokeStyle = '#ffd700';
ctx.lineWidth = 8;
ctx.strokeRect(170, 170, width - 340, height - 340);

// Corner decorations
function drawCornerDecoration(x, y, rotation) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotation);
    ctx.fillStyle = '#d4af37';
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(80, 0);
    ctx.lineTo(40, 40);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
}

drawCornerDecoration(150, 150, 0);
drawCornerDecoration(width - 150, 150, Math.PI / 2);
drawCornerDecoration(width - 150, height - 150, Math.PI);
drawCornerDecoration(150, height - 150, -Math.PI / 2);

// Elegant text
function drawElegantText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'center';
    
    // Shadow
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    ctx.fillText(text, width/2 + 4, yPos + 4);
    
    // Gold gradient on text
    const textGradient = ctx.createLinearGradient(0, yPos - fontSize/2, 0, yPos + fontSize/2);
    textGradient.addColorStop(0, '#ffd700');
    textGradient.addColorStop(0.5, '#ffed4e');
    textGradient.addColorStop(1, '#d4af37');
    
    // Outline
    ctx.strokeStyle = '#8b6914';
    ctx.lineWidth = 8;
    ctx.strokeText(text, width/2, yPos);
    
    // Glow
    ctx.shadowBlur = 40;
    ctx.shadowColor = '#ffd700';
    ctx.fillStyle = textGradient;
    ctx.fillText(text, width/2, yPos);
    ctx.shadowBlur = 0;
}

drawElegantText('AGED TO', height / 2 - 140, 120);
drawElegantText('PERFECTION', height / 2, 150);
drawElegantText('75 YEARS OF', height / 2 + 140, 100);
drawElegantText('AWESOME', height / 2 + 240, 130);

// Sparkles
ctx.fillStyle = 'rgba(255, 215, 0, 0.8)';
for (let i = 0; i < 40; i++) {
    const x = 200 + Math.random() * (width - 400);
    const y = 200 + Math.random() * (height - 400);
    const size = Math.random() * 4 + 2;
    
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(Math.random() * Math.PI);
    ctx.beginPath();
    ctx.moveTo(0, -size);
    ctx.lineTo(size/3, -size/3);
    ctx.lineTo(size, 0);
    ctx.lineTo(size/3, size/3);
    ctx.lineTo(0, size);
    ctx.lineTo(-size/3, size/3);
    ctx.lineTo(-size, 0);
    ctx.lineTo(-size/3, -size/3);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-perfection.png', buffer);
console.log('Perfection saved!');
