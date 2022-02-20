document.addEventListener('scroll', onScrollDoc);
document.querySelectorAll('[data-slider-control-prev]')
  .forEach(el => el.addEventListener('click', onClickSliderControlPrev));
document.querySelectorAll('[data-slider-control-next]')
  .forEach(el => el.addEventListener('click', onClickSliderControlNext));

let isForceScroll = false;

/**
 * @this {HTMLElement}
 * @param {Event} e
 */
function onScrollDoc(e) {
  const scrollY = document.scrollingElement.scrollTop;

  document.querySelectorAll('[data-horizontal-scroll-wrapper]')
    .forEach(el => {
      if (!isForceScroll) {
        const clientRect = el.getBoundingClientRect();
        const isInViewport = clientRect.top <= window.innerHeight && clientRect.bottom >= 0;

        if (isInViewport) {
          const offsetY = scrollY - clientRect.top + Number(el.dataset.horizontalScrollTargetOffsetY || 0);
          const scrollProgress = offsetY / clientRect.height;

          el.querySelectorAll('[data-horizontal-scroll-target]')
            .forEach(elEl => {
              if (scrollProgress <= 1) {
                elEl.scrollLeft = elEl.clientWidth * scrollProgress;
              }
            });
        }
      }
    });
}

/**
 * @this {HTMLElement}
 * @param {MouseEvent} e
 */
function onClickSliderControlPrev(e) {
  incrementSlider(this.dataset.sliderControlPrev, -1);
}

/**
 * @this {HTMLElement}
 * @param {MouseEvent} e
 */
function onClickSliderControlNext(e) {
  incrementSlider(this.dataset.sliderControlNext, 1);
}

/**
 * @param {string} sliderId 
 * @param {number} n 
 */
function incrementSlider(sliderId, n) {
  isForceScroll = true;

  document.querySelectorAll(`[data-slider="${sliderId}"]`)
    .forEach(el => {
      const currentIndex = Number(el.dataset.sliderIndex) || 0;
      const newIndex = currentIndex + n;
      const total = el.children.length;

      if (newIndex >= 0 && newIndex < total) {
        const slide = el.children[newIndex];

        slide.scrollIntoView({ behavior: 'smooth', inline: 'start', block: 'nearest' });
        el.dataset.sliderIndex = newIndex;
      }
    });

  isForceScroll = false;
}