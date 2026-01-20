<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>JEPANG — Jelajah Pangandaran</title>
  <meta name="description" content="Aplikasi mobile Flutter untuk eksplorasi wisata Pangandaran dengan UI modern, peta interaktif, dan REST API." />
  <style>
    :root{
      --bg:#0b1220;--card:#121a2b;--text:#e5e7eb;--muted:#9ca3af;--brand:#22c55e;--accent:#38bdf8;--border:#1f2937;
    }
    [data-theme="light"]{
      --bg:#f8fafc;--card:#ffffff;--text:#0f172a;--muted:#475569;--brand:#16a34a;--accent:#0284c7;--border:#e5e7eb;
    }
    *{box-sizing:border-box}
    body{margin:0;font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Ubuntu; background:linear-gradient(180deg,var(--bg),#020617); color:var(--text)}
    .container{max-width:1100px;margin:0 auto;padding:32px}
    header{display:grid;grid-template-columns:1fr auto;align-items:center;gap:16px}
    .toggle{border:1px solid var(--border);background:var(--card);color:var(--text);padding:10px 14px;border-radius:12px;cursor:pointer}
    .hero{display:grid;grid-template-columns:1.1fr .9fr;gap:28px;align-items:center;margin-top:24px}
    .card{background:linear-gradient(180deg,var(--card),rgba(255,255,255,.02));border:1px solid var(--border);border-radius:24px;box-shadow:0 20px 60px rgba(0,0,0,.25)}
    .pad{padding:28px}
    h1{font-size:56px;line-height:1.05;margin:0}
    h2{font-size:36px;margin:0 0 12px}
    h3{font-size:22px;margin:0 0 8px}
    p{color:var(--muted)}
    .badges{display:flex;flex-wrap:wrap;gap:10px;margin:16px 0}
    .badge{border:1px dashed var(--border);padding:8px 12px;border-radius:999px}
    .cta{display:flex;gap:12px;margin-top:16px}
    .btn{background:linear-gradient(135deg,var(--brand),#4ade80);color:#052e16;border:none;padding:14px 18px;border-radius:14px;font-weight:700;cursor:pointer}
    .btn.secondary{background:transparent;color:var(--text);border:1px solid var(--border)}
    .logo{width:120px;height:120px}
    .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}
    .shot{height:360px;border-radius:20px;border:1px solid var(--border);background:radial-gradient(120px 120px at 20% 10%,rgba(34,197,94,.25),transparent),linear-gradient(180deg,#020617,transparent)}
    .shot .bar{height:48px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px;padding:0 14px}
    .dot{width:10px;height:10px;border-radius:50%;background:#ef4444}
    .dot.y{background:#f59e0b}.dot.g{background:#22c55e}
    section{margin-top:42px}
    footer{margin-top:56px;padding-top:24px;border-top:1px solid var(--border);display:grid;grid-template-columns:1fr auto;gap:16px}
    .uas{font-size:14px;color:var(--muted)}
    @media(max-width:900px){.hero{grid-template-columns:1fr}.grid{grid-template-columns:1fr}}
  </style>
</head>
<body data-theme="dark">
  <div class="container">
    <header>
      <div style="display:flex;align-items:center;gap:16px">
        <!-- SVG LOGO -->
        <svg class="logo" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stop-color="#22c55e"/>
              <stop offset="100%" stop-color="#38bdf8"/>
            </linearGradient>
          </defs>
          <rect x="10" y="10" rx="28" ry="28" width="100" height="100" fill="url(#g)"/>
          <path d="M36 70c18-26 30-30 48-30" stroke="#052e16" stroke-width="6" fill="none" stroke-linecap="round"/>
          <circle cx="60" cy="60" r="8" fill="#052e16"/>
          <text x="60" y="102" text-anchor="middle" font-size="14" font-weight="800" fill="#052e16">JEPANG</text>
        </svg>
        <div>
          <h3>JEPANG</h3>
          <p>Jelajah Pangandaran</p>
        </div>
      </div>
      <button class="toggle" onclick="toggleTheme()">🌗 Light / Dark</button>
    </header>

    <div class="hero">
      <div class="card pad">
        <h1>Jelajah Pangandaran<br/>dalam Satu Genggaman</h1>
        <p>Aplikasi mobile Flutter dengan UI modern, peta interaktif, dan REST API untuk eksplorasi wisata Pangandaran.</p>
        <div class="badges">
          <span class="badge">Flutter</span><span class="badge">Dart</span><span class="badge">REST API</span><span class="badge">Maps</span>
        </div>
        <div class="cta">
          <button class="btn">Lihat Demo</button>
          <button class="btn secondary">GitHub Repo</button>
        </div>
      </div>
      <div class="grid">
        <!-- SCREENSHOT MOCKUPS -->
        <div class="shot card">
          <div class="bar"><span class="dot"></span><span class="dot y"></span><span class="dot g"></span></div>
        </div>
        <div class="shot card">
          <div class="bar"><span class="dot"></span><span class="dot y"></span><span class="dot g"></span></div>
        </div>
        <div class="shot card">
          <div class="bar"><span class="dot"></span><span class="dot y"></span><span class="dot g"></span></div>
        </div>
      </div>
    </div>

    <section class="card pad">
      <h2>Tentang Proyek</h2>
      <p><b>JEPANG (JElajah PANGAndaran)</b> adalah platform panduan wisata digital modern. Proyek ini menonjolkan kemampuan UI/UX, integrasi REST API, dan arsitektur Flutter yang rapi—cocok untuk portofolio dan penilaian akademik.</p>
    </section>

    <section class="card pad">
      <h2>Fitur Unggulan</h2>
      <div class="grid">
        <div><h3>Eksplor Destinasi</h3><p>Daftar wisata dengan thumbnail & kategori.</p></div>
        <div><h3>Detail & Galeri</h3><p>Foto, deskripsi, jam buka, dan kontak.</p></div>
        <div><h3>Peta Interaktif</h3><p>Marker lokasi & navigasi.</p></div>
      </div>
    </section>

    <footer>
      <div>
        <h3>Identitas UAS</h3>
        <p class="uas">Nama: <b>Haris Nurpazri</b><br/>NIM: <b>ISI_NIM_ANDA</b><br/>Kelas: <b>ISI_KELAS</b><br/>Dosen Pengampu: <b>ISI_NAMA_DOSEN</b></p>
      </div>
      <p class="uas">© 2026 — JEPANG • Flutter Portfolio</p>
    </footer>
  </div>

  <script>
    function toggleTheme(){
      const b=document.body; b.setAttribute('data-theme', b.getAttribute('data-theme')==='light'?'dark':'light');
    }
  </script>
</body>
</html>
