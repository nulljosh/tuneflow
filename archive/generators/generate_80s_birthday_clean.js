const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Gradient background
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#1a0033');
bgGradient.addColorStop(0.25, '#2d0066');
bgGradient.addColorStop(0.5, '#4d0099');
bgGradient.addColorStop(0.75, '#6600cc');
bgGradient.addColorStop(1, '#8000ff');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Stars
ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
for (let i = 0; i < 200; i++) {
    const x = Math.random() * width;
    const y = Math.random() * (height / 2);
    const size = Math.random() * 3;
    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.fill();
}

// Perspective grid
const gridStart = height / 2;
const gridSpacing = 80;

// Horizontal lines
ctx.strokeStyle = 'rgba(255, 0, 255, 0.6)';
ctx.lineWidth = 3;
for (let y = gridStart; y < height; y += gridSpacing) {
    const progress = (y - gridStart) / (height - gridStart);
    const offset = 400 * progress;
    ctx.beginPath();
    ctx.moveTo(offset, y);
    ctx.lineTo(width - offset, y);
    ctx.stroke();
}

// Vertical lines
ctx.strokeStyle = 'rgba(0, 255, 255, 0.6)';
for (let x = 0; x < width; x += gridSpacing) {
    const centerX = width / 2;
    const targetX = centerX + (x - centerX) * 2;
    ctx.beginPath();
    ctx.moveTo(x, gridStart);
    ctx.lineTo(targetX, height);
    ctx.stroke();
}

// Rainbow colors
const colors = ['#ff0080', '#ff0000', '#ff8000', '#ffff00', '#00ff00', '#00ffff', '#0080ff'];

// Draw text function
function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Glow layers
        for (let blur = 40; blur > 0; blur -= 10) {
            ctx.shadowBlur = blur;
            ctx.shadowColor = color;
            ctx.fillStyle = color;
            ctx.fillText(char, xPos, yPos);
        }
        
        ctx.shadowBlur = 0;
        ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
        ctx.fillText(char, xPos + 6, yPos + 6);
        
        ctx.shadowBlur = 30;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

// Draw clean, well-spaced text
drawText('HAPPY BIRTHDAY', height / 2 - 120, 140);
drawText('GRAMMA!', height / 2 + 100, 180);

// Scanlines
ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
for (let y = 0; y < height; y += 4) {
    ctx.fillRect(0, y, width, 2);
}

// Save
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/80s-birthday-gramma.png', buffer);
console.log('Image saved: Clean version with proper spacing');
