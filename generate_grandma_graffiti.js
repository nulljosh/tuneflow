const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Brick wall texture
ctx.fillStyle = '#8b4513';
ctx.fillRect(0, 0, width, height);

// Bricks
ctx.strokeStyle = '#654321';
ctx.lineWidth = 3;
for (let y = 0; y < height; y += 40) {
    for (let x = (y / 40) % 2 === 0 ? 0 : -100; x < width; x += 200) {
        ctx.strokeRect(x, y, 200, 40);
    }
}

// Add texture/grime
ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
for (let i = 0; i < 500; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const size = Math.random() * 50 + 10;
    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.fill();
}

// Graffiti colors - wild and bright
const colors = ['#ff00ff', '#00ffff', '#ffff00', '#ff0000', '#00ff00'];

function drawGraffitiText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        const rotation = (Math.random() - 0.5) * 0.15;
        const yOffset = Math.random() * 20 - 10;
        
        ctx.save();
        ctx.translate(xPos + ctx.measureText(char).width / 2, yPos + yOffset);
        ctx.rotate(rotation);
        
        // Multiple outline layers for 3D effect
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 18;
        ctx.strokeText(char, 0, 0);
        
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 12;
        ctx.strokeText(char, -2, -2);
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
        ctx.fillText(char, 5, 5);
        
        // Main color with glow
        ctx.shadowBlur = 30;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, 0, 0);
        
        // Highlight
        ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
        ctx.fillText(char, -3, -3);
        
        ctx.shadowBlur = 0;
        ctx.restore();
        
        xPos += ctx.measureText(char).width;
    });
}

drawGraffitiText('GRANDMA', height / 2 - 120, 180);
drawGraffitiText('FOREVER YOUNG', height / 2 + 80, 140);

// Spray paint drips
ctx.strokeStyle = 'rgba(255, 0, 255, 0.6)';
ctx.lineWidth = 8;
for (let i = 0; i < 15; i++) {
    const x = 300 + Math.random() * (width - 600);
    const y = height / 2 + 150;
    const length = Math.random() * 100 + 50;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + (Math.random() - 0.5) * 20, y + length);
    ctx.stroke();
}

// Tags/signatures
ctx.font = 'italic bold 40px Arial';
ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
ctx.fillText('75 & FRESH', width - 300, height - 100);

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-graffiti.png', buffer);
console.log('Graffiti saved!');
