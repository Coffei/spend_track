export function initAnalyticsCharts() {
  const container = document.getElementById('charts-container');
  if (!container) return;

  const categories = JSON.parse(container.dataset.categories);

  const spentCtx = document.getElementById('spentChart');
  const receivedCtx = document.getElementById('receivedChart');

  const formatCurrency = (value) => {
    const parts = value.toFixed(2).split('.');
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    return parts.join(',');
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'bottom',
      },
      title: {
        display: false
      },
      tooltip: {
        callbacks: {
          label: function(context) {
            let label = context.label || '';
            if (label) {
              label += ': ';
            }
            if (context.parsed !== null) {
              label += formatCurrency(context.parsed);
            }
            return label;
          }
        }
      }
    }
  };

  if (spentCtx) {
    const spentData = categories
      .filter(c => c.spent < 0)
      .map(c => ({
        label: c.name || 'Other',
        value: Math.abs(c.spent),
        color: c.color || '#cccccc'
      }));

    new Chart(spentCtx, {
      type: 'pie',
      data: {
        labels: spentData.map(d => d.label),
        datasets: [{
          data: spentData.map(d => d.value),
          backgroundColor: spentData.map(d => d.color),
          borderWidth: 1
        }]
      },
      options: chartOptions
    });
  }

  if (receivedCtx) {
    const receivedData = categories
      .filter(c => c.received > 0)
      .map(c => ({
        label: c.name || 'Other',
        value: c.received,
        color: c.color || '#cccccc'
      }));

    new Chart(receivedCtx, {
      type: 'pie',
      data: {
        labels: receivedData.map(d => d.label),
        datasets: [{
          data: receivedData.map(d => d.value),
          backgroundColor: receivedData.map(d => d.color),
          borderWidth: 1
        }]
      },
      options: chartOptions
    });
  }
}
