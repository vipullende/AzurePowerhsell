const form = document.querySelector('form');
form.addEventListener('submit', (event) => {
  event.preventDefault();
  const fileInput = document.querySelector('input[type="file"]');
  const file = fileInput.files[0];
  const SASInput = document.querySelector('input[name="SASToken"]');
  const SAS = SASInput.value;
  const xhr = new XMLHttpRequest();
  xhr.open('PUT', form.action + '/' + file.name + SAS);
  xhr.setRequestHeader('Content-Type', file.type);
  xhr.setRequestHeader('x-ms-blob-type', 'BlockBlob');
  xhr.send(file);
});
