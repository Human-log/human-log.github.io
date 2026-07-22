setInterval(() => {
  const s = document.querySelector('.status-bar');
  if (s) s.textContent = 'SYSTEM ONLINE // ' + new Date().toLocaleString() + ' // SECURE';
}, 1000);

const list = document.getElementById('post-list');
if (list) {
  fetch('posts.json').then(r => r.json()).then(posts => {
    list.innerHTML = '';
    posts.slice().reverse().forEach(p => {
      const li = document.createElement('li');
      li.className = 'post-item';
      li.innerHTML = '<h3><a href="post.html?s=' + p.slug + '">' + p.title + '</a></h3><div class="post-meta">[' + p.date + ']</div>';
      list.appendChild(li);
    });
  }).catch(() => { list.innerHTML = '<p>No posts yet.</p>'; });
}

const content = document.getElementById('post-content');
if (content) {
  const slug = new URLSearchParams(location.search).get('s');
  if (slug) {
    fetch('posts/' + slug + '.md').then(r => r.text()).then(md => {
      const d = md.match(/(\d{4}-\d{2}-\d{2})/);
      if (d) { const m = document.createElement('div'); m.className = 'post-meta'; m.textContent = '[' + d[1] + ']'; content.before(m); }
      const t = md.match(/^#\s+(.+)/m);
      if (t) document.title = t[1].trim() + ' — Human.Log';
      content.innerHTML = marked.parse(md);
    }).catch(() => { content.innerHTML = '<p>Post not found.</p>'; });
  }
}
