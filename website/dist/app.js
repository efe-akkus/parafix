const labels = { grafit: 'Grafit', orman: 'Orman', kum: 'Kum', pembe: 'Toz Pembe', bordo: 'Bordo', koyu: 'Koyu' };
const preview = document.querySelector('.theme-preview');
const label = document.querySelector('.theme-label');
document.querySelectorAll('.swatch').forEach((button) => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.swatch').forEach((swatch) => {
      const selected = swatch === button;
      swatch.classList.toggle('active', selected);
      swatch.setAttribute('aria-pressed', String(selected));
    });
    preview.dataset.previewTheme = button.dataset.theme;
    label.replaceChildren(document.createTextNode(labels[button.dataset.theme] + ' '));
    const hint = document.createElement('span');
    hint.textContent = '/ renk önizlemesi';
    label.append(hint);
  });
});
document.querySelector('#year').textContent = new Date().getFullYear();
