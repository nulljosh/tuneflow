const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Sunset gradient
const bgGradient = ctx.createLinearGradient(0, 0, 0, height);
bgGradient.addColorStop(0, '#ff6b35');
bgGradient.addColorStop(0.3, '#f7931e');
bgGradient.addColorStop(0.5, '#fdc500');
bgGradient.addColorStop(0.7, '#ff6ec7');
bgGradient.addColorStop(1, '#4a154b');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Sun
const sunGradient = ctx.createRadialGradient(width/2, height/2 + 150, 0, width/2, height/2 + 150, 350);
sunGradient.addColorStop(0, '#ffff00');
sunGradient.addColorStop(0.4, '#ff6b35');
sunGradient.addColorStop(1, 'rgba(255, 107, 53, 0)');
ctx.fillStyle = sunGradient;
ctx.beginPath();
ctx.arc(width/2, height/2 + 150, 350, 0, Math.PI * 2);
ctx.fill();

// Sun reflection on water
ctx.fillStyle = 'rgba(255, 200, 0, 0.3)';
for (let i = 0; i < 10; i++) {
    const y = height/2 + 300 + i * 40;
    const waveOffset = Math.sin(i * 0.5) * 100;
    ctx.fillRect(width/2 - 150 + waveOffset, y, 300, 15);
}

// Palm tree silhouette
ctx.fillStyle = '#000000';
// Left palm
ctx.fillRect(200, height - 400, 30, 400);
ctx.beginPath();
ctx.ellipse(215, height - 380, 100, 40, -0.5, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.ellipse(215, height - 390, 90, 35, -0.3, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.ellipse(215, height - 400, 110, 45, -0.7, 0, Math.PI * 2);
ctx.fill();

// Right palm
ctx.fillRect(1690, height - 350, 30, 350);
ctx.beginPath();
ctx.ellipse(1705, height - 330, 100, 40, 0.5, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.ellipse(1705, height - 340, 90, 35, 0.3, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.ellipse(1705, height - 350, 110, 45, 0.7, 0, Math.PI * 2);
ctx.fill();

// Text with tropical vibes
const colors = ['#ffffff', '#ffff00', '#ff69b4', '#00ffff'];

function drawText(text, yPos, fontSize) {
    ctx.font = `bold ${fontSize}px Impact, Arial Black, sans-serif`;
    ctx.textBaseline = 'middle';
    
    const totalWidth = ctx.measureText(text).width;
    let xPos = (width - totalWidth) / 2;
    
    text.split('').forEach((char, i) => {
        const color = colors[i % colors.length];
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
        ctx.fillText(char, xPos + 6, yPos + 6);
        
        // Outline
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 10;
        ctx.strokeText(char, xPos, yPos);
        
        // Glow
        ctx.shadowBlur = 40;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.fillText(char, xPos, yPos);
        ctx.shadowBlur = 0;
        
        xPos += ctx.measureText(char).width;
    });
}

drawText('LIVING MY', 250, 140);
drawText('BEST LIFE', 400, 160);
drawText('AT 75', 560, 140);

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/grandma-beach.png', buffer);
console.log('Beach saved!');
