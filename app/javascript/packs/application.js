import { Elm } from '../../elm/Main';
import Croppie from 'croppie/croppie';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].content
  const target = document.createElement('div')
  document.body.appendChild(target)
  const app = Elm.Main.init({
    node: target, flags: { csrfToken },
  })

  app.ports.initJsCropper.subscribe(function(data){
    const croppieButton = document.getElementById('croppie_button')
    const croppieTarget = document.getElementById('croppie')
    const opts = {
      url: data,
      viewport: { height: 300, width: 300 },
      boundary: { height: 400, width: 400 },
    }
    let croppie = new Croppie(croppieTarget, opts )
    croppieButton.addEventListener("click", function(){
      croppie.result({format: 'jpeg', type: 'base64'}).then(function(result){
        console.log(result)
        app.ports.sendCroppedImage.send(result)
      })
    })
  });
})
