async function fetchLatestNetworkSituation() {
  const a = 'https://aiu-portal.pockethost.io/api/collections/network_situation/records?sort=-date&perPage=1&skipTotal=1';
  try {
    const b = await fetch(a);
    if (!b.ok) throw new Error(`API call failed: ${b.status}`);
    const c = await b.json();
    return c.items[0]
  } catch (a) {
    return console.error("Failed to fetch latest network situation:", a), null
  }
}

async function updateNetworkSituationOnPage() {
  const a = await fetchLatestNetworkSituation();
  if (a) {
    const b = new Date(a.date),
      j = b.getFullYear(),
      e = b.getMonth(),
      f = new Date;
    f.setDate(b.getDate() - 6);
    const l = f.getMonth(),
      i = e == 0 ? `1` : `1 Jan`,
      d = `${(''+b.getDate()).slice(-2)} ${b.toLocaleString("en-US",{month:'short'})} ${j}`,
      c = `${d}`,
      h = `${i} - ${d}`,
      k = e == l ? `${(''+f.getDate()).slice(-2)}` : `${(''+f.getDate()).slice(-2)} ${f.toLocaleString("en-US",{month:"short"})}`,
      g = `${k} - ${d}`;
    document.getElementById("day_text_title").innerHTML = c,
    document.getElementById("day_text").innerHTML = c,
    document.getElementById("week_text").innerHTML = g,
    document.getElementById("y2d_text").innerHTML = h,
    document.getElementById("day_traffic").innerHTML = Math.round(a.day_traffic).toLocaleString(),
    document.getElementById("week_traffic").innerHTML = Math.round(a.avg_week_traffic).toLocaleString(),
    document.getElementById("y2d_traffic").innerHTML = Math.round(a.y2d_flights_total).toLocaleString(),
    document.getElementById("avg_y2d_traffic").innerHTML = Math.round(a.y2d_flights_daily_average).toLocaleString(),
    document.getElementById("dif_y2d_2019").innerHTML = (a.y2d_diff_2019_year_percentage > 0 ? '+' : '') + Math.round(a.y2d_diff_2019_year_percentage * 100) + '%',
    document.getElementById("dif_y2d_prev_year").innerHTML = (a.y2d_diff_previous_year_percentage > 0 ? '+' : '') + Math.round(a.y2d_diff_previous_year_percentage * 100) + '%',
    document.getElementById("dif_day_prev_week").innerHTML = (a.dif_day_prev_week > 0 ? '+' : '') + Math.round(a.dif_day_prev_week * 100) + '%',
    document.getElementById("dif_day_prev_year").innerHTML = (a.dif_day_prev_year > 0 ? '+' : '') + Math.round(a.dif_day_prev_year * 100) + '%',
    document.getElementById("dif_day_2019").innerHTML = (a.dif_day_2019 > 0 ? '+' : '') + Math.round(a.dif_day_2019 * 100) + '%',
    document.getElementById("dif_week_prev_week").innerHTML = (a.dif_week_prev_week > 0 ? '+' : '') + Math.round(a.dif_week_prev_week * 100) + '%',
    document.getElementById("dif_week_prev_year").innerHTML = (a.dif_week_prev_year > 0 ? '+' : '') + Math.round(a.dif_week_prev_year * 100) + '%',
    document.getElementById("dif_week_2019").innerHTML = (a.dif_week_2019 > 0 ? '+' : '') + Math.round(a.dif_week_2019 * 100) + '%';
    const m = c;
    document.getElementById("day_delay_text").innerHTML = m,
    document.getElementById("week_delay_text").innerHTML = g,
    document.getElementById("y2d_delay_text").innerHTML = h,
    document.getElementById("day_delay").innerHTML = Math.round(a.day_delay).toLocaleString(),
    document.getElementById("avg_week_delay").innerHTML = Math.round(a.avg_week_delay).toLocaleString(),
    document.getElementById("y2d_delay_daily_average").innerHTML = Math.round(a.y2d_delay_daily_average).toLocaleString(),
    document.getElementById("day_delay_flight").innerHTML = a.day_traffic == 0 ? 0 : Math.round(a.day_delay / a.day_traffic * 100) / 100,
    document.getElementById("week_delay_flight").innerHTML = a.avg_week_traffic == 0 ? 0 : Math.round(a.avg_week_delay / a.avg_week_traffic * 100) / 100,
    document.getElementById("y2d_delay_flight").innerHTML = a.y2d_flights_total == 0 ? 0 : Math.round(a.y2d_delay_total / a.y2d_flights_total * 100) / 100,
    document.getElementById("dif_day_delay_prev_year_perc").innerHTML = (a.dif_day_delay_prev_year_perc > 0 ? '+' : '') + Math.round(a.dif_day_delay_prev_year_perc * 100) + '%',
    document.getElementById("dif_day_delay_2019_perc").innerHTML = (a.dif_day_delay_2019_perc > 0 ? '+' : '') + Math.round(a.dif_day_delay_2019_perc * 100) + '%',
    document.getElementById("dif_week_delay_prev_year_perc").innerHTML = (a.dif_week_delay_prev_year_perc > 0 ? '+' : '') + Math.round(a.dif_week_delay_prev_year_perc * 100) + '%',
    document.getElementById("dif_week_delay_2019_perc").innerHTML = (a.dif_week_delay_2019_perc > 0 ? '+' : '') + Math.round(a.dif_week_delay_2019_perc * 100) + '%',
    document.getElementById("dif_y2d_delay_prev_year_perc").innerHTML = (a.dif_y2d_delay_prev_year_perc > 0 ? '+' : '') + Math.round(a.dif_y2d_delay_prev_year_perc * 100) + '%',
    document.getElementById("dif_y2d_delay_2019_perc").innerHTML = (a.dif_y2d_delay_2019_perc > 0 ? '+' : '') + Math.round(a.dif_y2d_delay_2019_perc * 100) + '%'
  } else console.log("No data available to update the network situation.")
}