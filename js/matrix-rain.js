const c = document.getElementById('matrix-canvas'), x = c.getContext('2d');
c.width = innerWidth; c.height = innerHeight;
const chars = 'アイウエオカキクケコサシスセソタチツテト0123456789ABCDEF';
const cols = c.width / 14, drops = Array.from({length: cols}, () => 1);
setInterval(() => {
  x.fillStyle = 'rgba(0,0,0,0.05)'; x.fillRect(0, 0, c.width, c.height);
  x.fillStyle = '#00ff41'; x.font = '14px monospace';
  for (let i = 0; i < drops.length; i++) {
    x.fillText(chars[Math.random() * chars.length | 0], i * 14, drops[i] * 14);
    if (drops[i] * 14 > c.height && Math.random() > 0.975) drops[i] = 0;
    drops[i]++;
  }
}, 35);
addEventListener('resize', () => { c.width = innerWidth; c.height = innerHeight; });
