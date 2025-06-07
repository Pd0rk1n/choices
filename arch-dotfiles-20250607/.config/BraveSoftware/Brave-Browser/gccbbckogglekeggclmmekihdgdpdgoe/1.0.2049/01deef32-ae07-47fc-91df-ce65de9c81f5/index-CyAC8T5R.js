function isAndroid() {
  return /Android/i.test(navigator.userAgent);
}
const dispatchedEvents = /* @__PURE__ */ new Set();
function dispatchNttEvent(eventType) {
  if (dispatchedEvents.has(eventType)) return;
  dispatchedEvents.add(eventType);
  const targetOrigin = isAndroid() ? "chrome://new-tab-takeover" : "chrome://newtab";
  window.parent.postMessage(
    { type: "richMediaEvent", value: eventType },
    targetOrigin
  );
}
function bindClickEvent(selector, handler) {
  document.querySelector(selector)?.addEventListener("click", handler);
}
function bindClickEvents(selectors, handler) {
  selectors.forEach((selector) => bindClickEvent(selector, handler));
}
function initCarousel() {
  const carousel = document.querySelector(".carousel");
  const slides = document.querySelectorAll(".carousel-slide");
  let currentSlide = 0;
  let autoplayInterval = null;
  if (!carousel || !slides) return;
  addEventListeners();
  setSlideFocalPoints();
  displaySlide(currentSlide);
  createPaginationDots();
  updatePaginationDots(currentSlide);
  maybeStartAutoplay();
  function setSlideFocalPoints() {
    document.querySelectorAll(".carousel-slide img").forEach((img) => {
      img.style.objectPosition = img.getAttribute("data-focal-point") || "center";
    });
  }
  function displaySlide(index) {
    if (index < 0 || index >= slides.length) return;
    const animationStyle = carousel.getAttribute("data-animation-style");
    if (animationStyle === "fade") {
      carousel.classList.add("fade");
      slides.forEach((slide, i) => {
        slide.classList.toggle("active", i === index);
      });
    } else {
      carousel.classList.remove("fade");
      carousel.style.transform = `translateX(${-index * 100}%)`;
    }
    updatePaginationDots(index);
  }
  function nextSlide(has_user_interaction = true) {
    resetAutoplay();
    currentSlide = (currentSlide + 1) % slides.length;
    displaySlide(currentSlide);
    if (has_user_interaction) {
      dispatchNttEvent("interaction");
    }
  }
  function prevSlide() {
    resetAutoplay();
    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
    displaySlide(currentSlide);
    dispatchNttEvent("interaction");
  }
  function createPaginationDots() {
    const paginationDotsContainer = document.getElementById(
      "carousel-pagination-dots-container"
    );
    if (!paginationDotsContainer) {
      return;
    }
    slides.forEach((_, i) => {
      const pagination_dot = Object.assign(document.createElement("span"), {
        className: "carousel-pagination-dot",
        onclick: () => {
          resetAutoplay();
          currentSlide = i;
          displaySlide(currentSlide);
          dispatchNttEvent("interaction");
        }
      });
      paginationDotsContainer.appendChild(pagination_dot);
    });
  }
  function updatePaginationDots(index) {
    if (index < 0 || index >= slides.length) return;
    document.querySelectorAll(".carousel-pagination-dot").forEach((paginationDot, i) => {
      paginationDot.classList.toggle("active", i === index);
    });
  }
  function addEventListeners() {
    document.addEventListener("visibilitychange", handleVisibilityChange);
    bindClickEvent(".carousel-slide img", () => dispatchNttEvent("click"));
    bindClickEvent(".carousel-navigation.next", () => nextSlide(true));
    bindClickEvent(".carousel-navigation.prev", prevSlide);
  }
  function maybeStartAutoplay() {
    const intervalInSeconds = Number(carousel.getAttribute("data-autoplay"));
    if (intervalInSeconds > 0) {
      startAutoplay(intervalInSeconds);
    }
  }
  function startAutoplay(intervalInSeconds) {
    if (autoplayInterval) clearInterval(autoplayInterval);
    autoplayInterval = setInterval(() => nextSlide(false), intervalInSeconds * 1e3);
  }
  function stopAutoplay() {
    if (autoplayInterval) clearInterval(autoplayInterval);
    autoplayInterval = null;
  }
  function resetAutoplay() {
    stopAutoplay();
    maybeStartAutoplay();
  }
  function handleVisibilityChange() {
    document.visibilityState === "visible" ? maybeStartAutoplay() : stopAutoplay();
  }
}
document.addEventListener("DOMContentLoaded", () => {
  initCarousel();
  bindClickEvents([".try-brave-vpn"], () => dispatchNttEvent("click"));
});
