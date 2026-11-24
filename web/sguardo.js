// Sguardo web kit: blur-in scroll reveal with a 50ms stagger between siblings.
(() => {
  const els = document.querySelectorAll('.sg-reveal');
  if (!('IntersectionObserver' in window)) { els.forEach(e => e.classList.add('is-in')); return; }
  const io = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      const i = [...el.parentElement.children].filter(c => c.classList.contains('sg-reveal')).indexOf(el);
      el.style.transitionDelay = `${Math.max(i, 0) * 50}ms`;
      el.classList.add('is-in');
      io.unobserve(el);
    });
  }, { rootMargin: '0px 0px -10% 0px', threshold: 0.12 });
  els.forEach(e => io.observe(e));
})();
