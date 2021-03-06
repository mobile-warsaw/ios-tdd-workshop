#import "Specs.h"
#import "PhotoStreamViewController.h"
#import "StreamItem.h"
#import "FakeStreamItemDownloader.h"


@interface PhotoStreamViewController ()
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) NSMutableArray *streamItems;
@end

SPEC_BEGIN(PhotoStreamViewController)
    describe(@"PhotoStreamViewController", ^{
        __block PhotoStreamViewController *photoStreamViewController;
        beforeEach(^{
            photoStreamViewController = [PhotoStreamViewController new];
        });
        afterEach(^{
            photoStreamViewController = nil;
        });

        describe(@"when created", ^{
            it(@"should have title set", ^{
                expect(photoStreamViewController.title).to.equal(@"Photo Stream");
            });
            it(@"should have right bar button item set", ^{
                expect(photoStreamViewController.navigationItem.rightBarButtonItem).notTo.beNil();
            });
            it(@"should have stream item uploader set", ^{
                expect(photoStreamViewController.streamItemUploader).notTo.beNil();
            });
            it(@"should have stream item creator set", ^{
                expect(photoStreamViewController.streamItemCreator).notTo.beNil();
            });
            it(@"should have stream item downloader set", ^{
                expect(photoStreamViewController.streamItemDownloader).notTo.beNil();
            });
        });

        describe(@"when view did load", ^{
            __block FakeStreamItemDownloader *fakeStreamItemDownloader;
            beforeEach(^{
                fakeStreamItemDownloader = [FakeStreamItemDownloader new];
                photoStreamViewController.streamItemDownloader = (id) fakeStreamItemDownloader;
                fakeStreamItemDownloader.delegate = photoStreamViewController;

                [photoStreamViewController view]; //to force the view to be loaded
            });
            it(@"should download stream items", ^{
                expect(fakeStreamItemDownloader.downloadStreamItemsCalled).to.beTruthy();
            });

            describe(@"and download succeeds", ^{
                __block NSArray *items;
                beforeEach(^{
                    items = @[];
                    [fakeStreamItemDownloader simulateDidDownloadItems:items];
                });

                it(@"should set stream items", ^{
                    expect(photoStreamViewController.streamItems).to.equal(items);
                });

                it(@"should stop animating refresh control", ^{
                    expect(photoStreamViewController.refreshControl.isRefreshing).to.beFalsy();
                });
            });
        });

        describe(@"when add bar button is pressed", ^{
            __block StreamItemCreator *itemCreatorMock;

            beforeEach(^{
                itemCreatorMock = mock([StreamItemCreator class]);
                photoStreamViewController.streamItemCreator = itemCreatorMock;

                UIBarButtonItem *barButtonItem = photoStreamViewController.navigationItem.rightBarButtonItem;
                [photoStreamViewController performSelector:barButtonItem.action withObject:barButtonItem];
            });
            it(@"should create stream item", ^{
                [verify(itemCreatorMock) createStreamItem];
            });
        });

        describe(@"when stream item is created", ^{
            __block StreamItemUploader *streamItemUploaderMock;
            __block StreamItemCreator *itemCreatorMock;
            __block StreamItem *testStreamItem;

            beforeEach(^{
                itemCreatorMock = mock([StreamItemCreator class]);
                streamItemUploaderMock = mock([StreamItemUploader class]);
                photoStreamViewController.streamItemUploader = streamItemUploaderMock;
                testStreamItem = [StreamItem new];

                [photoStreamViewController streamItemCreator:itemCreatorMock didCreateItem:testStreamItem];
            });
            it(@"should upload be uploaded to the server", ^{
                [verify(streamItemUploaderMock) uploadStreamItem:testStreamItem];
            });
        });

    });
SPEC_END
