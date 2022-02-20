document.addEventListener('scroll', onDocScroll);
document.addEventListener('click', onDocClick);
document.querySelectorAll('[data-slider-control-prev]')
  .forEach(el => el.addEventListener('click', onSliderControlPrevClick));
document.querySelectorAll('[data-slider-control-next]')
  .forEach(el => el.addEventListener('click', onSliderControlNextClick));

const onDocScrollState = {
  isForceScroll: false,
  isCurrentWrapper: false,
  // isPassingWrapper: false,
};

/**
 * @this {Document}
 * @param {Event} e
 */
function onDocScroll(e) {
  const scrollY = document.scrollingElement.scrollTop;

  document.querySelectorAll('[data-horizontal-scroll-wrapper]')
    .forEach(el => {
      const clientRect = el.getBoundingClientRect();

      onDocScrollState.isCurrentWrapper = clientRect.top <= window.innerHeight && clientRect.bottom >= 0;

      const isShouldScrollTheWrapper = !onDocScrollState.isForceScroll && onDocScrollState.isCurrentWrapper

      if (isShouldScrollTheWrapper) {
        const offsetY = scrollY - clientRect.top + Number(el.dataset.horizontalScrollTargetOffsetY || 0);
        const scrollProgress = offsetY / clientRect.height;

        el.querySelectorAll('[data-horizontal-scroll-target]')
          .forEach(elEl => {
            if (scrollProgress <= 1) {
              elEl.scrollLeft = elEl.clientWidth * scrollProgress;
            }
          });
      }
    });
}

/**
 * @this {Document}
 * @param {Event} e
 */
function onDocClick(e) {
  if (e.target instanceof HTMLAnchorElement) {
    onDocScrollState.isForceScroll = true;
  }
}

/**
 * @this {HTMLElement}
 * @param {MouseEvent} e
 */
function onSliderControlPrevClick(e) {
  incrementSlider(this.dataset.sliderControlPrev, -1);
}

/**
 * @this {HTMLElement}
 * @param {MouseEvent} e
 */
function onSliderControlNextClick(e) {
  incrementSlider(this.dataset.sliderControlNext, 1);
}

/**
 * @param {string} sliderId 
 * @param {number} n 
 */
function incrementSlider(sliderId, n) {
  onDocScrollState.isForceScroll = true;

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

  onDocScrollState.isForceScroll = false;
}