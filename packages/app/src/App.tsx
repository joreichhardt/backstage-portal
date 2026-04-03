import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import scaffolderPlugin from '@backstage/plugin-scaffolder/alpha';
import { navModule } from './modules/nav';
import { githubAuthApiRef } from '@backstage/core-plugin-api';
import { SignInPage } from '@backstage/core-components';
import { createExtension, coreExtensionData } from '@backstage/frontend-plugin-api';
import React from 'react';

const signInPageExtension = createExtension({
  name: 'signInPage',
  attachTo: { id: 'app/root', input: 'signInPage' },
  output: {
    component: coreExtensionData.reactElement,
  },
  factory: () => ({
    component: (
      <SignInPage
        auto
        providers={[
          'guest',
          {
            id: 'github-auth-provider',
            title: 'GitHub',
            message: 'Sign in using GitHub',
            apiRef: githubAuthApiRef,
          },
        ]}
      />
    ),
  }),
});

export default createApp({
  features: [
    catalogPlugin,
    scaffolderPlugin, // Das hier aktiviert die "/create" Seite
    navModule,
    signInPageExtension,
  ],
});
