$(document).ready(function() {
  $(".owl-carousel").owlCarousel({
    loop: true,
    margin: 0,
    nav: false,
    center: true,
    autoHeight: true,
    autoplay: true,
    autoplayHoverPause: true,
    responsive:{
        0:{
            items:1
        },
        600:{
            items:2
        },
        1000:{
            items:4
        }
    }
  });
});