const { createCanvas } = require('canvas');
const fs = require('fs');

const width = 1920;
const height = 1080;
const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

// Soft background gradient
const bgGradient = ctx.createRadialGradient(width/2, height/2, 0, width/2, height/2, height);
bgGradient.addColorStop(0, '#fff5f5');
bgGradient.addColorStop(1, '#ffc0cb');
ctx.fillStyle = bgGradient;
ctx.fillRect(0, 0, width, height);

// Table surface
ctx.fillStyle = '#d2b48c';
ctx.fillRect(0, height - 250, width, 250);

// Wood grain texture
ctx.strokeStyle = 'rgba(139, 69, 19, 0.2)';
ctx.lineWidth = 2;
for (let y = height - 250; y < height; y += 20) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    for (let x = 0; x < width; x += 50) {
        ctx.lineTo(x + Math.random() * 10, y + Math.random() * 5);
    }
    ctx.stroke();
}

// Cake shadow
ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
ctx.beginPath();
ctx.ellipse(width/2, height - 200, 420, 80, 0, 0, Math.PI * 2);
ctx.fill();

// Bottom cake layer - chocolate
const bottomLayer = ctx.createLinearGradient(0, height - 600, 0, height - 400);
bottomLayer.addColorStop(0, '#5c3a21');
bottomLayer.addColorStop(0.5, '#6f4e37');
bottomLayer.addColorStop(1, '#5c3a21');
ctx.fillStyle = bottomLayer;
ctx.fillRect(width/2 - 400, height - 600, 800, 200);

// Bottom layer frosting trim
ctx.fillStyle = '#ffb6c1';
ctx.fillRect(width/2 - 400, height - 610, 800, 20);
ctx.fillRect(width/2 - 400, height - 400, 800, 20);

// Middle cake layer - vanilla
const middleLayer = ctx.createLinearGradient(0, height - 520, 0, height - 370);
middleLayer.addColorStop(0, '#ffe5b4');
middleLayer.addColorStop(0.5, '#fff8dc');
middleLayer.addColorStop(1, '#ffe5b4');
ctx.fillStyle = middleLayer;
ctx.fillRect(width/2 - 350, height - 520, 700, 150);

// Middle layer frosting
ctx.fillStyle = '#ffb6c1';
ctx.fillRect(width/2 - 350, height - 530, 700, 20);
ctx.fillRect(width/2 - 350, height - 370, 700, 20);

// Top cake layer - strawberry
const topLayer = ctx.createLinearGradient(0, height - 450, 0, height - 330);
topLayer.addColorStop(0, '#ff69b4');
topLayer.addColorStop(0.5, '#ffb6d9');
topLayer.addColorStop(1, '#ff69b4');
ctx.fillStyle = topLayer;
ctx.fillRect(width/2 - 300, height - 450, 600, 120);

// Top layer frosting
ctx.fillStyle = '#ffe4e1';
ctx.fillRect(width/2 - 300, height - 460, 600, 20);
ctx.fillRect(width/2 - 300, height - 330, 600, 20);

// Cake top
const cakeTop = ctx.createRadialGradient(width/2, height - 330, 0, width/2, height - 330, 300);
cakeTop.addColorStop(0, '#ffffff');
cakeTop.addColorStop(0.7, '#ffe4e1');
cakeTop.addColorStop(1, '#ffb6d9');
ctx.fillStyle = cakeTop;
ctx.beginPath();
ctx.ellipse(width/2, height - 330, 300, 50, 0, 0, Math.PI * 2);
ctx.fill();

// Frosting decorations - rosettes
ctx.fillStyle = '#ff69b4';
for (let i = 0; i < 12; i++) {
    const angle = (i / 12) * Math.PI * 2;
    const x = width/2 + Math.cos(angle) * 250;
    const y = height - 330 + Math.sin(angle) * 40;
    
    for (let j = 0; j < 6; j++) {
        const petalAngle = (j / 6) * Math.PI * 2;
        ctx.beginPath();
        ctx.arc(x + Math.cos(petalAngle) * 8, y + Math.sin(petalAngle) * 3, 6, 0, Math.PI * 2);
        ctx.fill();
    }
}

// Candles
const candles = [
    {x: width/2 - 120, y: height - 380},
    {x: width/2 - 40, y: height - 390},
    {x: width/2 + 40, y: height - 390},
    {x: width/2 + 120, y: height - 380}
];

candles.forEach(candle => {
    // Candle body
    const candleGradient = ctx.createLinearGradient(candle.x - 8, 0, candle.x + 8, 0);
    candleGradient.addColorStop(0, '#ffb6d9');
    candleGradient.addColorStop(0.5, '#ff69b4');
    candleGradient.addColorStop(1, '#ffb6d9');
    ctx.fillStyle = candleGradient;
    ctx.fillRect(candle.x - 8, candle.y, 16, 60);
    
    // Wick
    ctx.fillStyle = '#333333';
    ctx.fillRect(candle.x - 1, candle.y - 10, 2, 12);
    
    // Flame
    const flameGradient = ctx.createRadialGradient(candle.x, candle.y - 15, 0, candle.x, candle.y - 15, 15);
    flameGradient.addColorStop(0, '#ffffff');
    flameGradient.addColorStop(0.3, '#ffff00');
    flameGradient.addColorStop(0.6, '#ffa500');
    flameGradient.addColorStop(1, 'rgba(255, 69, 0, 0)');
    ctx.fillStyle = flameGradient;
    ctx.beginPath();
    ctx.ellipse(candle.x, candle.y - 15, 12, 18, 0, 0, Math.PI * 2);
    ctx.fill();
    
    // Flame glow
    ctx.shadowBlur = 20;
    ctx.shadowColor = '#ffa500';
    ctx.fill();
    ctx.shadowBlur = 0;
});

// Text on cake
ctx.font = 'bold 80px "Brush Script MT", cursive, Arial';
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';

// Text shadow
ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
ctx.fillText('Happy Birthday', width/2 + 2, height - 520 + 2);
ctx.fillText('Grandma!', width/2 + 2, height - 440 + 2);

// Text main
const textGradient = ctx.createLinearGradient(0, height - 550, 0, height - 420);
textGradient.addColorStop(0, '#ff1493');
textGradient.addColorStop(0.5, '#ff69b4');
textGradient.addColorStop(1, '#ff1493');
ctx.fillStyle = textGradient;
ctx.fillText('Happy Birthday', width/2, height - 520);
ctx.fillText('Grandma!', width/2, height - 440);

// Text outline
ctx.strokeStyle = '#ffffff';
ctx.lineWidth = 3;
ctx.strokeText('Happy Birthday', width/2, height - 520);
ctx.strokeText('Grandma!', width/2, height - 440);

const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('/Users/joshua/.openclaw/workspace/birthday-cake-grandma.png', buffer);
console.log('Birthday cake saved!');
