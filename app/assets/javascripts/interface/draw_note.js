/**
 * @author Max Stillwell
 */

function draw_note(note_type, x, y, width, height) 
{
    var ctx = document.getElementById('note_view').getContext('2d');
    var img = new Image();
    img.onload = function()
    {
      ctx.beginPath()
        ctx.drawImage(img, x, y, width, height)
      ctx.closePath();
      ctx.stroke();
    };
    img.src = 'images/quater_note.png';
}