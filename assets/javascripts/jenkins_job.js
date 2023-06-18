function addJenkinsBuildRow(parent, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('.expander')) {
            ex.addEventListener('click', toggleJenkinsJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doJenkinsAction);
            }
        }

        parent.after(child);
        parent = child;
    }
}

function addJenkinsFolderRow(parent, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('.expander')) {
            ex.addEventListener('click', toggleJenkinsFolder);
        }

        for (const ex of child.querySelectorAll('input[type="checkbox"]')) {
            ex.addEventListener('change', toggleJenkinsFileCheckbox);
        }

        parent.after(child);
        parent = child;
    }
}

function replaceJenkinsBuildRow(target, data) {
    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('.expander')) {
            ex.addEventListener('click', toggleJenkinsJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doJenkinsAction);
            }
        }

        target.replaceWith(child);
    }
}

function replaceJenkinsJobRow(job, data) {
    collapseJenkinsJobRow(job);

    for (var build of document.querySelectorAll(`.${job.id}`)) {
        build.remove();
    }

    const container = document.createElement('tbody');
    container.innerHTML = data;

    for (const child of container.querySelectorAll('tr')) {
        for (const ex of child.querySelectorAll('.expander')) {
            ex.addEventListener('click', toggleJenkinsJob);
        }

        for (const row of container.querySelectorAll('td.operation')) {
            for (const action of row.querySelectorAll('a')) {
                action.addEventListener('click', doJenkinsAction);
            }
        }

        job.replaceWith(child);
    }
}

function displayJenkinsBuild(job) {
    for (const child of document.querySelectorAll(`.${job.id}`)) {
        if (!child.classList.contains('collapsed')) {
            displayJenkinsBuild(child);
        }

        child.style.display = '';
    }
}

function displayJenkinsFolder(folder) {
    for (const child of document.querySelectorAll(`.${folder.id}`)) {
        if (child.classList.contains('jenkins-folder') &&
            !child.classList.contains('collapsed')) {
            displayJenkinsFolder(child);
        }

        child.style.display = '';
    }
}

function hideJenkinsBuild(job) {
    for (const child of document.querySelectorAll(`.${job.id}`)) {
        if (!child.classList.contains('collapsed')) {
            hideJenkinsBuild(child);
        }

        child.style.display = 'none';
    }
}

function hideJenkinsFolder(folder) {
    for (const child of document.querySelectorAll(`.${folder.id}`)) {
        if (child.classList.contains('jenkins-folder') &&
            !child.classList.contains('collapsed')) {
            hideJenkinsFolder(child);
        }

        child.style.display = 'none';
    }
}

function collapseJenkinsFolderRow(row) {
    hideJenkinsFolder(row);

    const expander = row.querySelector('.expander');
    expander.classList.remove('icon-expended');
    expander.classList.remove('icon-expanded');
    expander.classList.add('collapsed');
    expander.classList.add('icon-collapsed');

    row.classList.remove('open');
    row.classList.add('collapsed');
}

function collapseJenkinsJobRow(row) {
    hideJenkinsBuild(row);

    const expander = row.querySelector('.expander');
    expander.classList.remove('icon-expended');
    expander.classList.remove('icon-expanded');
    expander.classList.add('collapsed');
    expander.classList.add('icon-collapsed');

    row.classList.add('collapsed');
}

function expandJenkinsFolderRow(row) {
    row.classList.remove('collapsed');
    row.classList.add('open');

    const expander = row.querySelector('.expander');
    expander.classList.remove('collapsed');
    expander.classList.remove('icon-collapsed');
    expander.classList.add('icon-expended');
    expander.classList.add('icon-expanded');

    displayJenkinsFolder(row);
}

function expandJenkinsJobRow(row) {
    row.classList.remove('collapsed');

    const expander = row.querySelector('.expander');
    expander.classList.remove('collapsed');
    expander.classList.remove('icon-collapsed');
    expander.classList.add('icon-expended');
    expander.classList.add('icon-expanded');

    displayJenkinsBuild(row);
}

function toggleJenkinsFileCheckbox(e) {
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

    refreshJenkinsCount();
}

function toggleJenkinsFolder(e) {
    e.preventDefault();

    const row = document.getElementById(e.target.dataset.id);
    if (!row.classList.contains('collapsed')) {
        collapseJenkinsFolderRow(row);
        return;
    } else if (row.classList.contains('loaded')) {
        expandJenkinsFolderRow(row);
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

    showJenkinsInProgress(jenkinsLoadingMessage);
    row.classList.add('loading');
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                addJenkinsFolderRow(row, data);

                row.classList.remove('loading');
                row.classList.add('loaded');

                expandJenkinsFolderRow(row);
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function toggleJenkinsJob(e) {
    e.preventDefault();

    const row = document.getElementById(e.target.dataset.id);
    if (!row.classList.contains('collapsed')) {
        collapseJenkinsJobRow(row);
        return;
    } else if (row.classList.contains('loaded')) {
        expandJenkinsJobRow(row);
        return;
    } else if (row.classList.contains('loading')) {
        return;
    }

    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showJenkinsInProgress(jenkinsLoadingMessage);
    row.classList.add('loading');
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                addJenkinsBuildRow(row, data);

                row.classList.remove('loading');
                row.classList.add('loaded');

                expandJenkinsJobRow(row);
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function toggleJenkinsServer(target) {
    for (const field of document.getElementById('jenkins-server-fields').querySelectorAll('input')) {
        if (field.id != 'jenkins-enable') {
            field.disabled = !target.checked;
        }
    }

    const enableServerSecret = document.getElementById('jenkins-enable-secret');
    toggleJenkinsServerSecret(enableServerSecret);
}

function toggleJenkinsServerSecret(target) {
    const secret = document.getElementById('jenkins-server-fields').querySelector('input[name="password"]');
    secret.disabled = target.disabled || !target.checked;
}

function execJenkinsBuild(job, e) {
    const csrf = document.querySelector('meta[name="csrf-token"]').content;

    const option = {
        method: 'POST',
        cache: 'no-cache',
        headers: {
            'X-CSRF-TOKEN': csrf
        }
    };

    showJenkinsInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                job.querySelector('a.icon-reload').click();
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}


function refreshJenkinsJob(job, e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showJenkinsInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                replaceJenkinsJobRow(job, data);
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function refreshJenkinsBuild(build, e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    //showJenkinsInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                //closeJenkinsInProgress();

                replaceJenkinsBuildRow(build, data);
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function refreshJenkinsCount() {
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

function displayJenkinsArtifact(e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showJenkinsInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                const modal = document.getElementById('artifactModal');
                modal.querySelector("section").innerHTML = data;
                modal.showModal();
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function displayJenkinsOutput(e) {
    const option = {
        method: 'GET',
        cache: 'no-cache',
    };

    showJenkinsInProgress(jenkinsLoadingMessage);
    fetch(e.target.dataset.url, option).then(function (response) {
        if (response.ok) {
            response.text().then(function (data) {
                closeJenkinsInProgress();

                const modal = document.getElementById('outputModal');
                modal.querySelector("section").innerText = data;
                modal.showModal();
            });
        } else {
            closeJenkinsInProgress();
            alert(`${response.status} : ${response.statusText}`);
        }
    });
}

function doJenkinsAction(e) {
    e.preventDefault();

    const jobId = e.target.dataset.jobId;

    if (jobId == null) {
        const jobId = e.target.dataset.id;
        const job = document.getElementById(jobId);

        if (e.target.classList.contains('icon-add')) {
            execJenkinsBuild(job, e);
        } else if (e.target.classList.contains('icon-reload')) {
            refreshJenkinsJob(job, e);
        } else if (e.target.classList.contains('text-plain')) {
            displayJenkinsOutput(e);
        } else if (e.target.classList.contains('icon-download')) {
            displayJenkinsArtifact(e);
        } else {
            console.log(e);
        }
    } else {
        const id = e.target.dataset.id;
        const buildId = `${jobId}-${id}`
        const build = document.getElementById(buildId);

        if (e.target.classList.contains('icon-reload')) {
            refreshJenkinsBuild(build, e);
        } else if (e.target.classList.contains('text-plain')) {
            displayJenkinsOutput(e);
        } else if (e.target.classList.contains('icon-download')) {
            displayJenkinsArtifact(e);
        } else {
            console.log(e);
        }
    }
}

function showJenkinsInProgress(message) {
    const modal = document.getElementById('loadingModal');
    modal.querySelector("section").innerText = message;
    modal.showModal();
}

function closeJenkinsInProgress() {
    const modal = document.getElementById('loadingModal');
    modal.close();
}

function refreshJenkinsInProgressBuild() {
    for (const build of document.querySelectorAll('tr.jenkins-build')) {
        const status = build.querySelector('td.jenkins-build-inprogress');
        if (status != null) {
            build.querySelector('a.icon-reload').click();
        }
    }

    setTimeout(refreshJenkinsInProgressBuild, 3000);
}
