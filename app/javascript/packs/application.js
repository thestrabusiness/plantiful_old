import { Elm } from '../../elm/Main';
import Croppie from 'croppie/croppie';

function rafAsync() {
  return new Promise(resolve => {
    requestAnimationFrame(resolve); //faster than set time out
  });
}

function checkElement(selector) {
  if (document.querySelector(selector) === null) {
    return rafAsync().then(() => checkElement(selector));
  } else {
    return Promise.resolve(true);
  }
}

function viewportDimensions () {
  if(window.innerWidth <= 1100) {
    return { height: 500, width: 500 }
  } else {
    return { height: 300, width: 300 }
  }
}

function boundaryDimensions () {
  if(window.innerWidth <= 1100) {
    return { height: 800, width: 800 }
  } else {
    return { height: 400, width: 400 }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].content
  const target = document.createElement('div')
  document.body.appendChild(target)
  const app = Elm.Main.init({
    node: target, flags: { csrfToken },
  })

  app.ports.initJsCropper.subscribe(async function(data){
    checkElement('#croppie').then(result =>{
      const croppieTarget = document.getElementById('croppie')
      const croppieButton = document.getElementById('croppie_button')
      const opts = {
        url: data,
        viewport: viewportDimensions(),
        boundary: boundaryDimensions(),
      }
      let croppie = new Croppie(croppieTarget, opts )
      croppieButton.addEventListener("click", function(){
        croppie.result({format: 'jpeg', type: 'base64'}).then(function(result){
          app.ports.sendCroppedImage.send(result)
        })
      })
    });
  });
})
