<script>
document.querySelectorAll('.callout[data-activity-number]').forEach((activity) => {
  const title = activity.querySelector('.callout-title-container');
  if (title) {
    title.textContent = `Activity ${activity.dataset.activityNumber}: ${activity.getAttribute('title')}`;

    const levelInfo = document.createElement('button');
    levelInfo.type = 'button';
    levelInfo.className = 'activity-level-info';
    levelInfo.setAttribute('aria-label', 'Explain activity levels');
    levelInfo.setAttribute('aria-expanded', 'false');
    levelInfo.textContent = 'i';

    const levelPopup = document.createElement('div');
    levelPopup.className = 'activity-level-popup';
    levelPopup.setAttribute('role', 'tooltip');
    levelPopup.hidden = true;
    levelPopup.innerHTML = '<strong>Activity levels</strong><br>●○○ Beginner: introductory concepts and guided steps.<br>●●○ Intermediate: some prior knowledge and independent application.<br>●●● Advanced: complex tasks requiring substantial prior knowledge.';

    levelInfo.addEventListener('click', () => {
      levelPopup.hidden = !levelPopup.hidden;
      levelInfo.setAttribute('aria-expanded', String(!levelPopup.hidden));
    });

    title.append(levelInfo, levelPopup);
  }
});
</script>
