const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Rock concert poster background - dark with spotlight
const bgGradient = ctx.createRadialGradient(width/2, height/3, 0, width/2, height/2, height);
bgGradient.addColorStop(0, '#ffff00');
bgGradient.addColorStop(0.3, '#ff00ff');
bgGradient.addColorStop(0.6, '#8b008b');
bgGradient.addColorStop(1, '#000000');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Add rock texture with diagonal lines
ctx.strokeStyle = 'rgba(255, 255, 255, 0.05)';
ctx.lineWidth = 3;
for (let i = -height; i < width + height; i += 30) {
    ctx.beginPath();
    ctx.moveTo(i, 0);
    ctx.lineTo(i + height * 1.5, height);
    ctx.stroke();
}

// Lightning bolts
ctx.strokeStyle = 'rgba(255, 255, 0, 0.6)';
ctx.lineWidth = 8;
function drawLightning(x, y) {
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x - 30, y + 80);
    ctx.lineTo(x - 10, y + 80);
    ctx.lineTo(x - 40, y + 160);
    ctx.lineTo(x - 20, y + 160);
    ctx.lineTo(x - 50, y + 240);
    ctx.stroke();
}
drawLightning(200, 100);
drawLightning(1700, 150);

// Rock star colors
const colors = ['#ff0000', '#ffff00', '#ff00ff', '#00ff00'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Heavy black outline
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 15;
        ctx.strokeText(char, xPos, yPos);
        
        // Inner glow
        ctx.shadowBlur = 50;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText("GRANDMA'S", height / 2 - 180, 110);
drawText("75TH BIRTHDAY", height / 2 - 50, 130);
drawText("BASH", height / 2 + 90, 140);
drawText("STILL ROCKING", height / 2 + 230, 90);

// Add stars
ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
for (let i = 0; i < 30; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    const size = Math.random() * 5 + 2;
    
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(Math.random() * Math.PI);
    ctx.beginPath();
    for (let j = 0; j < 5; j++) {
        ctx.lineTo(0, -size);
        ctx.rotate(Math.PI / 5);
        ctx.lineTo(0, -size/2);
        ctx.rotate(Math.PI / 5);
    }
    ctx.closePath();
    ctx.fill();
    ctx.restore();
}

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-rockstar.png', buffer);
console.log('Rock star birthday saved!');
