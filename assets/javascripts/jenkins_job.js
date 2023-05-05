function addBuildRow(parent, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('span.expander')) {
            ex.addEventListener('click', toggleJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doAction);
            }
        }

        parent.after(child);
        parent = child;
    }
}

function addFolderRow(parent, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('span.expander')) {
            ex.addEventListener('click', toggleFolder);
        }

        for (const ex of child.querySelectorAll('input[type="checkbox"]')) {
            ex.addEventListener('change', toggleFileCheckbox);
        }

        parent.after(child);
        parent = child;
    }
}

function replaceBuildRow(target, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('span.expander')) {
            ex.addEventListener('click', toggleJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doAction);
            }
        }

        target.replaceWith(child);
    }
}

function replaceJobRow(job, data) {
    collapseJobRow(job);

    for (var build of document.querySelectorAll(`.${job.id}`)) {
        build.remove();
    }

    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('span.expander')) {
            ex.addEventListener('click', toggleJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doAction);
            }
        }

        job.replaceWith(child);
    }
}

function displayBuild(job) {
    for (const child of document.querySelectorAll(`.${job.id}`)) {
        if (!child.classList.contains('collapsed')) {
            displayBuild(child);
        }

        child.style.display = '';
    }
}

function displayFolder(folder) {
    for (const child of document.querySelectorAll(`.${folder.id}`)) {
        if (child.classList.contains('jenkins-folder') &&
            !child.classList.contains('collapsed')) {
            displayFolder(child);
        }

        child.style.display = '';
    }
}

function hideBuild(job) {
    for (const child of document.querySelectorAll(`.${job.id}`)) {
        if (!child.classList.contains('collapsed')) {
            hideBuild(child);
        }

        child.style.display = 'none';
    }
}

function hideFolder(folder) {
    for (const child of document.querySelectorAll(`.${folder.id}`)) {
        if (child.classList.contains('jenkins-folder') &&
            !child.classList.contains('collapsed')) {
            hideFolder(child);
        }

        child.style.display = 'none';
    }
}

function collapseFolderRow(row) {
    hideFolder(row);

    row.classList.remove('open');
    row.querySelector('.expander').classList.replace('icon-expended', 'icon-collapsed');
    row.classList.add('collapsed');
}

function collapseJobRow(row) {
    hideBuild(row);

    row.querySelector('.expander').classList.replace('icon-expended', 'icon-collapsed');
    row.classList.add('collapsed');
}

function expandFolderRow(row) {
    row.classList.remove('collapsed');
    row.querySelector('.expander').classList.replace('icon-collapsed', 'icon-expended');
    row.classList.add('open');

    displayFolder(row);
}

function expandJobRow(row) {
    row.classList.remove('collapsed');
    row.querySelector('.expander').classList.replace('icon-collapsed', 'icon-expended');

    displayBuild(row);
}

function toggleFileCheckbox(e) {
    const jobId = e.target.id.slice('toggle-'.length);
    const job = document.getElementById(jobId);

    const monitoringList = document.getElementById('monitoring-job-list');
    const monitotingJob = monitoringList.querySelector(`#enable-${jobId}`);
    if (monitotingJob == null) {
        const box = document.createElement('input');
        box.type = 'checkbox';
        box.id = `enable-${jobId}`;
        box.name = 'monitoring_jobs[]';
        box.value = job.dataset.jobPath;
        box.checked = true;

        monitoringList.appendChild(box);
    } else {
        monitotingJob.checked = e.target.checked;
    }

    refreshCount();
}

function toggleFolder(e) {
    e.preventDefault();

    const row = document.getElementById(e.target.dataset.id);
    if (!row.classList.contains('collapsed')) {
        collapseFolderRow(row);
        return;
    } else if (row.classList.contains('loaded')) {
        expandFolderRow(row);
        return;
    } else if (row.classList.contains('loading')) {
        return;
    }

    const csrf = document.querySelector('input[name="authenticity_token"]').value;

    const option = {
        method: 'GET',
        cache: 'no-cache',
        headers: {
            'X-CSRF-TOKEN': csrf
        }
    };

    showInProgress(jenkinsLoadingMessage);
    row.classList.add('loading');
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            addFolderRow(row, data);

            row.classList.remove('loading');
            row.classList.add('loaded');

            expandFolderRow(row);
        });
    });
}

function toggleJob(e) {
    e.preventDefault();

    const row = document.getElementById(e.target.dataset.id);
    if (!row.classList.contains('collapsed')) {
        collapseJobRow(row);
        return;
    } else if (row.classList.contains('loaded')) {
        expandJobRow(row);
        return;
    } else if (row.classList.contains('loading')) {
        return;
    }

    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showInProgress(jenkinsLoadingMessage);
    row.classList.add('loading');
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            addBuildRow(row, data);

            row.classList.remove('loading');
            row.classList.add('loaded');

            expandJobRow(row);
        });
    });
}

function toggleServer(target) {
    for (const field of document.getElementById('jenkins-server-fields').querySelectorAll('input')) {
        if (field.id != 'jenkins-enable') {
            field.disabled = !target.checked;
        }
    }

    const enableServerSecret = document.getElementById('jenkins-enable-secret');
    toggleServerSecret(enableServerSecret);
}

function toggleServerSecret(target) {
    const secret = document.getElementById('jenkins-server-fields').querySelector('input[name="secret"]');
    secret.disabled = target.disabled || !target.checked;
}

function execBuild(job, e) {
    const csrf = document.querySelector('meta[name="csrf-token"]').content;

    const option = {
        method: 'POST',
        cache: 'no-cache',
        headers: {
            'X-CSRF-TOKEN': csrf
        }
    };

    showInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            job.querySelector('a.icon-reload').click();
        });
    });
}


function refreshJob(job, e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            replaceJobRow(job, data);
        });
    });
}

function refreshBuild(build, e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    //showInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            //closeInProgress();

            replaceBuildRow(build, data);
        });
    });
}

function refreshCount() {
    const monitoringList = document.getElementById('monitoring-job-list');
    const enabledJobs = [...monitoringList.querySelectorAll('input[type="checkbox"]')]
        .filter(function (e) {
            return e.checked;
        })
        .map(function (e) {
            return e.value;
        });

    for (const folder of document.querySelectorAll('tr.jenkins-folder')) {
        const count = enabledJobs.reduce(function (sum, v) {
            return sum + (v.startsWith(folder.dataset.jobPath) ? 1 : 0);
        }, 0);

        document.getElementById(`count-${folder.id}`).innerText = count;
    }
}

function displayArtifact(e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            const modal = document.getElementById('artifactModal');
            modal.querySelector("section").innerHTML = data;
            modal.showModal();
        });
    });
}

function displayOutput(e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        response.text().then(function (data) {
            closeInProgress();

            const modal = document.getElementById('outputModal');
            modal.querySelector("section").innerText = data;
            modal.showModal();
        });
    });
}

function doAction(e) {
    e.preventDefault();

    const jobId = e.target.dataset.jobId;

    if (jobId == null) {
        const jobId = e.target.dataset.id;
        const job = document.getElementById(jobId);

        if (e.target.classList.contains('icon-add')) {
            execBuild(job, e);
        } else if (e.target.classList.contains('icon-reload')) {
            refreshJob(job, e);
        } else if (e.target.classList.contains('text-plain')) {
            displayOutput(e);
        } else if (e.target.classList.contains('icon-download')) {
            displayArtifact(e);
        } else {
            console.log(e);
        }
    } else {
        const id = e.target.dataset.id;
        const buildId = `${jobId}-${id}`
        const build = document.getElementById(buildId);

        if (e.target.classList.contains('icon-reload')) {
            refreshBuild(build, e);
        } else if (e.target.classList.contains('text-plain')) {
            displayOutput(e);
        } else if (e.target.classList.contains('icon-download')) {
            displayArtifact(e);
        } else {
            console.log(e);
        }
    }
}

function showInProgress(message) {
    const modal = document.getElementById('loadingModal');
    modal.querySelector("section").innerText = message;
    modal.showModal();
}

function closeInProgress() {
    const modal = document.getElementById('loadingModal');
    modal.close();
}

function refreshInProgressBuild() {
    for (const build of document.querySelectorAll('tr.jenkins-build')) {
        const status = build.querySelector('td.jenkins-build-inprogress');
        if (status != null) {
            build.querySelector('a.icon-reload').click();
        }
    }

    setTimeout(refreshInProgressBuild, 3000);
}
