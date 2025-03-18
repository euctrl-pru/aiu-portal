async function fetchLatestNetworkSituation() {
    const apiUrl = 'https://aiu-portal.pockethost.io/api/collections/network_situation/records?sort=-date&perPage=1&skipTotal=1';
    try {
        const response = await fetch(apiUrl);
        if (!response.ok) throw new Error(`API call failed: ${response.status}`);
        const data = await response.json();
        return data.items[0];
    } catch (error) {
        console.error("Failed to fetch latest network situation:", error);
        return null;
    }
}

async function updateNetworkSituationOnPage() {
    const networkSituation = await fetchLatestNetworkSituation();
    if (networkSituation) {
        const currentDate = new Date(networkSituation.date);
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();
        const weekStartDate = new Date();
        weekStartDate.setDate(currentDate.getDate() - 6);
        const weekStartMonth = weekStartDate.getMonth();

        const dayText = `${currentDate.getDate().toString().padStart(2, '0')} ${currentDate.toLocaleString("en-US", { month: 'short' })} ${year}`;
        const y2dText = `${month === 0 ? '1' : '1 Jan'} - ${dayText}`;

        // Update Y2D elements
        const updateElement = (id, value) => {
            const element = document.getElementById(id);
            if (element) {
                element.innerHTML = value;
            } else {
                console.error(`Element with ID '${id}' not found`);
            }
        };

        updateElement('y2d_text', y2dText);
        updateElement('y2d_traffic', Math.round(networkSituation.y2d_flights_total).toLocaleString());
        updateElement('avg_y2d_traffic', Math.round(networkSituation.y2d_flights_daily_average).toLocaleString());
        updateElement('dif_y2d_prev_year', (networkSituation.y2d_diff_previous_year_percentage > 0 ? '+' : '') + Math.round(networkSituation.y2d_diff_previous_year_percentage * 100) + '%');
        updateElement('dif_y2d_2019', (networkSituation.y2d_diff_2019_year_percentage > 0 ? '+' : '') + Math.round(networkSituation.y2d_diff_2019_year_percentage * 100) + '%');
    } else {
        console.log("No data available to update the network situation.");
    }
}
